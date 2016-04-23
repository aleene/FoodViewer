//
//  ProductsArray.swift
//  FoodViewer
//
//  Created by arnaud on 07/04/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

class OFFProducts {
    
    // This class is implemented as a singleton
    // The productsArray is only needed by the ProductsViewController
    // Unfortunately moving to another VC deletes the products, so it must be stored somewhere more permanently.
    // A singleton limits however the number of file loads
    
    struct Notification {
        static let ProductNotAvailable = "Product Not Available"
        static let ProductLoaded = "Product Loaded"
        static let FirstProductLoaded = "First Product Loaded"
        static let HistoryIsLoaded = "History Is Loaded"
        static let ProductUpdated = "Product Updated"
    }
    
    static let manager = OFFProducts()
    
    var mostRecentProduct = MostRecentProduct()

    var list = [FoodProduct?]()
    
    init() {
        // check if there is history available
        // and init products with History
        if !storedHistory.barcodes.isEmpty {
            historyLoadCount = 0
            initList()
            
            if let data = mostRecentProduct.jsonData {
                let fetchResult = OpenFoodFactsRequest().fetchStoredProduct(data)
                switch fetchResult {
                case .Success(let newProduct):
                    list[0] = newProduct
                    historyLoadCount! += 1
                    for (index, storedBarcode) in storedHistory.barcodes.enumerate() {
                        // skip the first in the history as it already has been loaded
                        if index > 0 {
                            fetchHistoryProduct(FoodProduct(withBarcode: BarcodeType(value: storedBarcode)), index:index)
                        }
                    }
                case .Error(let error):
                    let userInfo = ["error":error]
                    self.handleError(userInfo)
                }
                
            } else {
                for (index, storedBarcode) in storedHistory.barcodes.enumerate() {
                    // fetch the corresponding data from internet
                    fetchHistoryProduct(FoodProduct(withBarcode: BarcodeType(value: storedBarcode)), index:index)
                }
            }
        } else {
            historyLoadCount = nil
            let fetchResult = OpenFoodFactsRequest().fetchSampleProduct()
            switch fetchResult {
            case .Success(let newProduct):
                list.append(newProduct)
                loadSampleImages()
                NSNotificationCenter.defaultCenter().postNotificationName(Notification.FirstProductLoaded, object:nil)
            case .Error(let error):
                let userInfo = ["error":error]
                self.handleError(userInfo)
            }
        }
    }
    
    func loadSampleImages() {
        list[0]?.mainImageData = NSData(contentsOfFile: "SampleMain")
        list[0]?.ingredientsImageData = NSData(contentsOfFile: "SampleIngredients")
        list[0]?.nutritionImageData = NSData(contentsOfFile: "SampleNutrition")
    }
    
    private func initList() {
        for _ in 0..<storedHistory.barcodes.count {
            list.append(nil)
        }
    }
    
    func removeAll() {
            storedHistory = History()
            list = []
    }
    
    var storedHistory = History()

    private func fetchHistoryProduct(product: FoodProduct?, index: Int) {
        if let barcodeToFetch = product?.barcode {
            let request = OpenFoodFactsRequest()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            // loading the product from internet will be done off the main queue
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                let fetchResult = request.fetchProductForBarcode(barcodeToFetch)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    switch fetchResult {
                    case .Success(let newProduct):
                        self.list[index] = newProduct
                        self.historyLoadCount! += 1
                    case .Error(let error):
                        let userInfo = ["error":error]
                        self.handleError(userInfo)
                    }
                })
            })
        }
    }


    private var historyLoadCount: Int? = nil {
        didSet {
            if let currentLoadHistory = historyLoadCount {
                if currentLoadHistory == storedHistory.barcodes.count {
                    // all products have been loaded from history
                    historyLoadCount = nil
                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.ProductLoaded, object:nil)
                } else if historyLoadCount == 1 {
                    // the first product is already there, so can be shown
                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.FirstProductLoaded, object:nil)
                }
            }
        }
    }

    func fetchProduct(barcode: BarcodeType?) {
        if (barcode != nil) && (barcodeIsNew(barcode!)) {
            let request = OpenFoodFactsRequest()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            // loading the product from internet will be done off the main queue
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                let fetchResult = request.fetchProductForBarcode(barcode!)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    switch fetchResult {
                    case .Success(let newProduct):
                        self.list.insert(newProduct, atIndex:0)
                        // add product barcode to history
                        self.storedHistory.addBarcode(barcode: newProduct.barcode.asString())
                        self.loadMainImage(newProduct)
                        self.saveMostRecentProduct(barcode!)
                        NSNotificationCenter.defaultCenter().postNotificationName(Notification.FirstProductLoaded, object:nil)
                    case .Error(let error):
                        let userInfo = ["error":error]
                        self.handleError(userInfo)
                    }
                })
            })
        }
    }
    
    func saveMostRecentProduct(barcode: BarcodeType?) {
        if barcode != nil {
            let request = OpenFoodFactsRequest()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            // loading the product from internet will be done off the main queue
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                let fetchResult = request.fetchJsonForBarcode(barcode!)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    switch fetchResult {
                    case .Success(let newData):
                        self.mostRecentProduct.addMostRecentProduct(newData)
                    case .Error(let error):
                        let userInfo = ["error":error]
                        self.handleError(userInfo)
                    }
                })
            })
        }
    }
    
    func handleError(userInfo: [String:String]) {
        NSNotificationCenter.defaultCenter().postNotificationName(Notification.ProductNotAvailable, object:nil, userInfo: userInfo)
    }

    private func barcodeIsNew(newBarcode: BarcodeType) -> Bool {
        for product in list {
            if product!.barcode.asString() == newBarcode.asString() {
                return false
            }
        }
        return true
    }
    
    func reload(product: FoodProduct) {
        let request = OpenFoodFactsRequest()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            // loading the product from internet will be done off the main queue
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
            let fetchResult = request.fetchProductForBarcode(product.barcode)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                switch fetchResult {
                case .Success(let newProduct):
                    self.update(newProduct)
                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.ProductUpdated, object:nil)
                case .Error(let error):
                    let userInfo = ["error":error]
                    self.handleError(userInfo)
                }
            })
        })
    }
    
    private func update(updatedProduct: FoodProduct) {
        // where is product in the list?
        var index = 0
        for product in list {
            if product!.barcode.asString() == updatedProduct.barcode.asString() {
                // replace the existing product with the data of the new product
                product!.updateDataWith(updatedProduct)
                // i sthis the first product in the list
                if index == 0 {
                    // then the stored version must also be updated with this new product
                    saveMostRecentProduct(product!.barcode)
                }
            }
            index += 1
        }
    }
    
    func flushImages() {
        for product in list {
            product!.mainImageData = nil
            product!.ingredientsImageData = nil
            product!.nutritionImageData = nil
        }
    }
    
    /*
    private func updateProduct(product: FoodProduct?) {
        if let productToUpdate = product {
            // should check if the product is not already available
            if !list.isEmpty {
                // look at all products
                var indexExistingProduct: Int? = nil
                for index in 0 ..< list.count {
                    // print("products \(products[index].barcode.asString()); update \(productToUpdate.barcode.asString())")
                    if list[index].barcode.asString() == productToUpdate.barcode.asString() {
                        indexExistingProduct = index
                    }
                }
                if indexExistingProduct == nil {
                    // new product not yet in products array
                    // print("ADD product \(productToUpdate.barcode.asString())")
                    self.list.append(productToUpdate)
                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.ProductLoaded, object:nil)
                    // add product barcode to history
                    self.storedHistory.addBarcode(barcode: productToUpdate.barcode.asString())
                } else {
                    // print("UPDATE product \(productToUpdate.barcode.asString())")
                    // reset product information to the retrieved one
                    self.list[indexExistingProduct!] = productToUpdate
                    if historyLoadCount != nil {
                        historyLoadCount! += 1
                    }
                }
            } else {
                // print("FIRST product \(productToUpdate.barcode.asString())")
                
                // this is the first product of the array
                list.append(productToUpdate)
                // add product barcode to history
                self.storedHistory.addBarcode(barcode: productToUpdate.barcode.asString())
            }
            // launch image retrieval if needed
            if (productToUpdate.mainUrl != nil) {
                if (productToUpdate.mainImageData == nil) {
                    // get image only if the data is not there yet
                    retrieveImage(productToUpdate.mainUrl!)
                }
            }
        }
    }
    */
    private func loadMainImage(product: FoodProduct) {
        if (product.mainUrl != nil) {
            if (product.mainImageData == nil) {
                // get image only if the data is not there yet
                retrieveImage(product.mainUrl!)
            }
        }
    }
    
    private func loadMainThumbnailImage(product: FoodProduct) {
        if  (product.mainUrlThumb != nil) &&
            (product.mainImageSmallData == nil) {
                // get image only if the data is not there yet
                retrieveMainThumbnailImage(product.mainUrlThumb!)
        }
    }

    private func retrieveImage(url: NSURL?) {
            if let imageURL = url {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    do {
                        // This only works if you add a line to your Info.plist
                        // See http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http
                        //
                        let imageData = try NSData(contentsOfURL: imageURL, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                        if imageData.length > 0 {
                            // if we have the image data we can go back to the main thread
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                // set the received image data
                                // as we are on another thread I should find the product to add it to
                                if !self.list.isEmpty {
                                    // look at all products
                                    var indexExistingProduct: Int? = nil
                                    for index in 0 ..< self.list.count {
                                        if self.list[index]?.mainUrl == imageURL {
                                            indexExistingProduct = index
                                        }
                                    }
                                    if indexExistingProduct != nil {
                                        self.list[indexExistingProduct!]!.mainImageData = imageData
                                    }
                                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.ProductLoaded, object:nil)
                                } // else bad luck corresponding product is no longer there
                            })
                        }
                    }
                    catch {
                        print(error)
                    }
                })
            }
        }
        
    private func retrieveMainThumbnailImage(url: NSURL?) {
        if let imageURL = url {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                do {
                    // This only works if you add a line to your Info.plist
                    // See http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http
                    //
                    let imageData = try NSData(contentsOfURL: imageURL, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                    if imageData.length > 0 {
                        // if we have the image data we can go back to the main thread
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            // set the received image data
                            // as we are on another thread I should find the product to add it to
                            if !self.list.isEmpty {
                                // look at all products
                                var indexExistingProduct: Int? = nil
                                for index in 0 ..< self.list.count {
                                    if self.list[index]?.mainUrlThumb == imageURL {
                                        indexExistingProduct = index
                                    }
                                }
                                if indexExistingProduct != nil {
                                    self.list[indexExistingProduct!]!.mainImageSmallData = imageData
                                }
                            } // else bad luck corresponding product is no longer there
                        })
                    }
                }
                catch {
                    print(error)
                }
            })
        }
    }
    

}