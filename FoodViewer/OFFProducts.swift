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
        static let ProductLoadingError = "Product Loading Error"
    }
    
    static let manager = OFFProducts()
    
    var mostRecentProduct = MostRecentProduct()

    var fetchResultList = [ProductFetchStatus?]()
    
    init() {
        // Initialize the products, multiple options are possible:
        // - there is no history, the user usese the app the first time for instance -> show a sample product
        // - there are products in the history file
        //      check first if the most recent product has been stored and load that one
        //      then load the rest of the history products
        
        if !storedHistory.barcodes.isEmpty {
            initList()
            
            if let data = mostRecentProduct.jsonData {
                var fetchResult = ProductFetchStatus.Loading
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                    fetchResult = OpenFoodFactsRequest().fetchStoredProduct(data)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.historyLoadCount = 0
                        self.historyLoadCount! += 1
                        self.fetchResultList[0] = fetchResult
                        switch fetchResult {
                        case .Success:
                            NSNotificationCenter.defaultCenter().postNotificationName(Notification.FirstProductLoaded, object:nil)
                        case .LoadingFailed(let error):
                            let userInfo = ["error":error]
                            self.handleLoadingFailed(userInfo)
                        case .ProductNotAvailable(let error):
                            let userInfo = ["error":error]
                            self.handleProductNotAvailable(userInfo)
                        default: break
                        }
                    })
                })
                
            } else {
                historyLoadCount = 0
            }
        } else {
            // no history available, load sample product
            historyLoadCount = nil
            var fetchResult = ProductFetchStatus.Loading
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                fetchResult = OpenFoodFactsRequest().fetchSampleProduct()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.fetchResultList.append(fetchResult)
                    switch fetchResult {
                    case .Success:
                        self.loadSampleImages()
                        NSNotificationCenter.defaultCenter().postNotificationName(Notification.FirstProductLoaded, object:nil)
                    case .LoadingFailed(let error):
                        let userInfo = ["error":error]
                        self.handleLoadingFailed(userInfo)
                    case .ProductNotAvailable(let error):
                        let userInfo = ["error":error]
                        self.handleProductNotAvailable(userInfo)
                    default: break
                    }
                })
            })
        }
    }
    
    func loadSampleImages() {

        // The images are read from the assets catalog as UIImage
        // this ensure that the right resolution will be read
        // and then they are interbally stored as PNG data
        
        if let validFetchResult = fetchResultList[0] {
            switch validFetchResult {
            case .Success(let sampleProduct):
                if let image = UIImage(named: "SampleMain") {
                    if let data = UIImagePNGRepresentation(image) {
                        sampleProduct.mainImageData = .Success(data)
                    }
                } else {
                    sampleProduct.mainImageData = .NoData
                }
                
                if let image = UIImage(named: "SampleIngredients") {
                    if let data = UIImagePNGRepresentation(image) {
                        sampleProduct.ingredientsImageData = .Success(data)
                    }
                } else {
                    sampleProduct.ingredientsImageData = .NoData
                }
                
                if let image = UIImage(named: "SampleNutrition") {
                    if let data = UIImagePNGRepresentation(image) {
                        sampleProduct.nutritionImageData = .Success(data)
                    }
                } else {
                    sampleProduct.nutritionImageData = .NoData
                }
                
                sampleProduct.name = NSLocalizedString("Sample Product for Demonstration, the globally known M&M's", comment: "Product name of the product shown at first start")
                sampleProduct.genericName = NSLocalizedString("This sample product shows you how a product is presented. Slide to the following pages, in order to see more product details. Once you start scanning barcodes, you will no longer see this sample product.", comment: "An explanatory text in the common name field.")
                
            default: break
            }
        }
        
            }
    
    private func initList() {
        for _ in 0..<storedHistory.barcodes.count {
            fetchResultList.append(nil)
        }
    }
    
    func removeAll() {
            storedHistory = History()
            fetchResultList = []
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
                    self.fetchResultList[index] = fetchResult
                    switch fetchResult {
                    case .Success:
                        self.historyLoadCount! += 1
                    case .LoadingFailed(let error):
                        self.historyLoadCount! += 1
                        let userInfo = ["error":error]
                        self.handleLoadingFailed(userInfo)
                    case .ProductNotAvailable:
                        // product barcode no longer exists
                        self.historyLoadCount! += 1
                        // let userInfo = ["error":error]
                        // self.handleProductNotAvailable(userInfo)
                    default: break
                    }
                })
            })
        }
    }

    // This function manages the loading of the history products. A load batch is never larger than 5 simultaneous threads
    private var historyLoadCount: Int? = nil {
        didSet {
            if let currentLoadHistory = historyLoadCount {
                let batchSize = 5
                if currentLoadHistory == storedHistory.barcodes.count - 1 {
                    // all products have been loaded from history
                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.ProductLoaded, object:nil)
                } else if (currentLoadHistory >= 4) && ((currentLoadHistory + 1 ) % batchSize == 0) {
                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.ProductLoaded, object:nil)
                    // load next batch
                    let startIndex = currentLoadHistory + 1 <= storedHistory.barcodes.count - 1 ? currentLoadHistory + 1 : storedHistory.barcodes.count - 1
                    let endIndex = startIndex + batchSize - 1 <= storedHistory.barcodes.count - 1 ? startIndex + batchSize - 1 : storedHistory.barcodes.count - 1
                    for index in startIndex...endIndex {
                        fetchHistoryProduct(FoodProduct(withBarcode: BarcodeType(value: storedHistory.barcodes[index])), index:index)
                    }
                } else if (currentLoadHistory == 0) {
                    // the first product is already there, so can be shown
                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.FirstProductLoaded, object:nil)
                    // load first batch up to product 4
                    let startIndex = 1 <= storedHistory.barcodes.count ? 1 : storedHistory.barcodes.count - 1
                    let endIndex = startIndex + batchSize - 1 <= storedHistory.barcodes.count - 1 ? batchSize - 1 : storedHistory.barcodes.count - 1
                    for index in startIndex...endIndex {
                        fetchHistoryProduct(FoodProduct(withBarcode: BarcodeType(value: storedHistory.barcodes[index])), index:index)
                    }
                }
            }
        }
    }

    func fetchProduct(barcode: BarcodeType?) -> Int? {
        
        if let newBarcode = barcode {
            // is the product already in the history list?
            if let productIndexInHistory = isProductInHistory(newBarcode) {
                return productIndexInHistory
            } else {
                // retrieve this new product
                let request = OpenFoodFactsRequest()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                // loading the product from internet will be done off the main queue
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    let fetchResult = request.fetchProductForBarcode(barcode!)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        switch fetchResult {
                        case .Success(let newProduct):
                        // add product barcode to history
                            self.fetchResultList.insert(fetchResult, atIndex:0)
                            self.storedHistory.addBarcode(barcode: newProduct.barcode.asString())
                            // self.loadMainImage(newProduct)
                            self.saveMostRecentProduct(barcode!)
                            NSNotificationCenter.defaultCenter().postNotificationName(Notification.FirstProductLoaded, object:nil)
                        case .LoadingFailed(let error):
                            self.fetchResultList.insert(fetchResult, atIndex:0)
                            let userInfo = ["error":error]
                            self.handleLoadingFailed(userInfo)
                        case .ProductNotAvailable(let error):
                            let userInfo = ["error":error]
                            self.handleProductNotAvailable(userInfo)
                        default: break
                        }
                    })
                })
                return nil
            }
        } else {
            return nil
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
                        self.handleLoadingFailed(userInfo)
                    }
                })
            })
        }
    }
    
    // MARK: - Create notifications

    func handleProductNotAvailable(userInfo: [String:String]) {
        NSNotificationCenter.defaultCenter().postNotificationName(Notification.ProductNotAvailable, object:nil, userInfo: userInfo)
    }

    func handleLoadingFailed(userInfo: [String:String]) {
        NSNotificationCenter.defaultCenter().postNotificationName(Notification.ProductLoadingError, object:nil, userInfo: userInfo)
    }

    private func isProductInHistory(newBarcode: BarcodeType) -> Int? {
        for (index, fetchResult) in fetchResultList.enumerate() {
            if let validFetchResult = fetchResult {
                switch validFetchResult {
                case .Success(let product):
                    if product.barcode.asString() == newBarcode.asString() {
                        return index
                    }
                default:
                    break
                }

            }
        }
        return nil
    }
    
    func reload(product: FoodProduct) {
        let request = OpenFoodFactsRequest()
        var fetchResult = ProductFetchStatus.Loading
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            // loading the product from internet will be done off the main queue
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
            fetchResult = request.fetchProductForBarcode(product.barcode)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                switch fetchResult {
                case .Success(let newProduct):
                    self.update(newProduct)
                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.ProductUpdated, object:nil)
                case .LoadingFailed(let error):
                    let userInfo = ["error":error]
                    self.handleLoadingFailed(userInfo)
                case .ProductNotAvailable(let error):
                    let userInfo = ["error":error]
                    self.handleProductNotAvailable(userInfo)
                default:
                    break
                }
            })
        })
    }
    
    private func update(updatedProduct: FoodProduct) {
        // where is product in the list?
        var index = 0
        for fetchResult in fetchResultList {
            if let validFetchResult = fetchResult {
                switch validFetchResult {
                case .Success(let product):
                    if product.barcode.asString() == updatedProduct.barcode.asString() {
                        // replace the existing product with the data of the new product
                        product.updateDataWith(updatedProduct)
                        // i sthis the first product in the list
                        if index == 0 {
                            // then the stored version must also be updated with this new product
                            saveMostRecentProduct(product.barcode)
                        }
                    }
                    index += 1
                default:
                    break
                }
            } else {
                print("error: OFFProducts.update - fetchResult is nil")
            }

        }
    }
    
    func flushImages() {
        for fetchResult in fetchResultList {
            if let validFetchResult = fetchResult {
                switch validFetchResult {
                case .Success(let product):
                    product.mainImageData = nil
                    product.ingredientsImageData = nil
                    product.nutritionImageData = nil
                default:
                    break
                }
            } else {
                print("error: OFFProducts.flushImages - fetchResult is nil")
            }
        }
    }

}