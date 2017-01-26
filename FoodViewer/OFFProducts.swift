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
    internal struct Notification {
        static let BarcodeDoesNotExistKey = "OFFProducts.Notification.BarcodeDoesNotExist.Key"
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
                var fetchResult = ProductFetchStatus.loading
                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
                    fetchResult = OpenFoodFactsRequest().fetchStoredProduct(data)
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.historyLoadCount = 0
                        self.historyLoadCount! += 1
                        self.fetchResultList[0] = fetchResult
                        switch fetchResult {
                        case .success:
                            NotificationCenter.default.post(name: .FirstProductLoaded, object:nil)
                        case .loadingFailed(let error):
                            let userInfo = ["error":error]
                            self.handleLoadingFailed(userInfo)
                        case .productNotAvailable(let error):
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
            loadSampleProduct()
        }
    }
    
    private func loadSampleProduct() {
        // no history available, load sample product
        historyLoadCount = nil
        var fetchResult = ProductFetchStatus.loading
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
            fetchResult = OpenFoodFactsRequest().fetchSampleProduct()
            DispatchQueue.main.async(execute: { () -> Void in
                self.fetchResultList.append(fetchResult)
                switch fetchResult {
                case .success:
                    self.loadSampleImages()
                    NotificationCenter.default.post(name: .FirstProductLoaded, object:nil)
                case .loadingFailed(let error):
                    let userInfo = ["error":error]
                    self.handleLoadingFailed(userInfo)
                case .productNotAvailable(let error):
                    let userInfo = ["error":error]
                    self.handleProductNotAvailable(userInfo)
                default: break
                }
            })
        })
    }
    
    func loadSampleImages() {

        // The images are read from the assets catalog as UIImage
        // this ensure that the right resolution will be read
        // and then they are interbally stored as PNG data
        
        if let validFetchResult = fetchResultList[0] {
            switch validFetchResult {
            case .success(let sampleProduct):
                if let image = UIImage(named: "SampleMain") {
                    if let data = UIImagePNGRepresentation(image) {
                        sampleProduct.mainImageData = .success(data)
                    }
                } else {
                    sampleProduct.mainImageData = .noData
                }
                
                if let image = UIImage(named: "SampleIngredients") {
                    if let data = UIImagePNGRepresentation(image) {
                        sampleProduct.ingredientsImageData = .success(data)
                    }
                } else {
                    sampleProduct.ingredientsImageData = .noData
                }
                
                if let image = UIImage(named: "SampleNutrition") {
                    if let data = UIImagePNGRepresentation(image) {
                        sampleProduct.nutritionImageData = .success(data)
                    }
                } else {
                    sampleProduct.nutritionImageData = .noData
                }
                
                sampleProduct.name = NSLocalizedString("Sample Product for Demonstration, the globally known M&M's", comment: "Product name of the product shown at first start")
                sampleProduct.genericName = NSLocalizedString("This sample product shows you how a product is presented. Slide to the following pages, in order to see more product details. Once you start scanning barcodes, you will no longer see this sample product.", comment: "An explanatory text in the common name field.")
                
            default: break
            }
        }
        
            }
    
    fileprivate func initList() {
        for _ in 0..<storedHistory.barcodes.count {
            fetchResultList.append(nil)
        }
    }
    
    func removeAll() {
            storedHistory = History()
            fetchResultList = []
            loadSampleProduct()
    }
    
    var storedHistory = History()

    fileprivate func fetchHistoryProduct(_ product: FoodProduct?, index: Int) {
        if let barcodeToFetch = product?.barcode {
            let request = OpenFoodFactsRequest()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            // loading the product from internet will be done off the main queue
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
                let fetchResult = request.fetchProductForBarcode(barcodeToFetch)
                DispatchQueue.main.async(execute: { () -> Void in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.fetchResultList[index] = fetchResult
                    switch fetchResult {
                    case .success:
                        self.historyLoadCount! += 1
                    case .loadingFailed(let error):
                        self.historyLoadCount! += 1
                        let userInfo = ["error":error]
                        self.handleLoadingFailed(userInfo)
                    case .productNotAvailable:
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
    fileprivate var historyLoadCount: Int? = nil {
        didSet {
            if let currentLoadHistory = historyLoadCount {
                let batchSize = 5
                if currentLoadHistory == storedHistory.barcodes.count - 1 {
                    // all products have been loaded from history
                    NotificationCenter.default.post(name: .ProductLoaded, object:nil)
                } else if (currentLoadHistory >= 4) && ((currentLoadHistory + 1 ) % batchSize == 0) {
                    NotificationCenter.default.post(name: .ProductLoaded, object:nil)
                    // load next batch
                    let startIndex = currentLoadHistory + 1 <= storedHistory.barcodes.count - 1 ? currentLoadHistory + 1 : storedHistory.barcodes.count - 1
                    let endIndex = startIndex + batchSize - 1 <= storedHistory.barcodes.count - 1 ? startIndex + batchSize - 1 : storedHistory.barcodes.count - 1
                    for index in startIndex...endIndex {
                        fetchHistoryProduct(FoodProduct(withBarcode: BarcodeType(value: storedHistory.barcodes[index])), index:index)
                    }
                } else if (currentLoadHistory == 0) {
                    // the first product is already there, so can be shown
                    NotificationCenter.default.post(name:  .FirstProductLoaded, object:nil)
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

    func fetchProduct(_ barcode: BarcodeType?) -> Int? {
        
        if let newBarcode = barcode {
            // is the product already in the history list?
            if let productIndexInHistory = isProductInHistory(newBarcode) {
                return productIndexInHistory
            } else {
                // retrieve this new product
                let request = OpenFoodFactsRequest()
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                // loading the product from internet will be done off the main queue
                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    let fetchResult = request.fetchProductForBarcode(barcode!)
                    DispatchQueue.main.async(execute: { () -> Void in
                        switch fetchResult {
                        case .success(let newProduct):
                        // add product barcode to history
                            self.fetchResultList.insert(fetchResult, at:0)
                            self.storedHistory.addBarcode(barcode: newProduct.barcode.asString())
                            // self.loadMainImage(newProduct)
                            self.saveMostRecentProduct(barcode!)
                            NotificationCenter.default.post(name: .FirstProductLoaded, object:nil)
                        case .loadingFailed(let error):
                            self.fetchResultList.insert(fetchResult, at:0)
                            let userInfo = ["error":error]
                            self.handleLoadingFailed(userInfo)
                        case .productNotAvailable(let error):
                            let userInfo = [Notification.BarcodeDoesNotExistKey:newBarcode.asString(), "error":error]
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
    
    func saveMostRecentProduct(_ barcode: BarcodeType?) {
        if barcode != nil {
            let request = OpenFoodFactsRequest()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            // loading the product from internet will be done off the main queue
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                let fetchResult = request.fetchJsonForBarcode(barcode!)
                DispatchQueue.main.async(execute: { () -> Void in
                    switch fetchResult {
                    case .success(let newData):
                        self.mostRecentProduct.addMostRecentProduct(newData)
                    case .error(let error):
                        let userInfo = ["error":error]
                        self.handleLoadingFailed(userInfo)
                    }
                })
            })
        }
    }
    
    // MARK: - Create notifications

    func handleProductNotAvailable(_ userInfo: [String:String]) {
        NotificationCenter.default.post(name: .ProductNotAvailable, object:nil, userInfo: userInfo)
    }

    func handleLoadingFailed(_ userInfo: [String:String]) {
        NotificationCenter.default.post(name: .ProductLoadingError, object:nil, userInfo: userInfo)
    }

    fileprivate func isProductInHistory(_ newBarcode: BarcodeType) -> Int? {
        for (index, fetchResult) in fetchResultList.enumerated() {
            if let validFetchResult = fetchResult {
                switch validFetchResult {
                case .success(let product):
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
    
    func reload(_ product: FoodProduct) {
        let request = OpenFoodFactsRequest()
        var fetchResult = ProductFetchStatus.loading
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
            // loading the product from internet will be done off the main queue
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
            fetchResult = request.fetchProductForBarcode(product.barcode)
            DispatchQueue.main.async(execute: { () -> Void in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                switch fetchResult {
                case .success(let newProduct):
                    self.update(newProduct)
                    NotificationCenter.default.post(name: .ProductUpdated, object:nil)
                case .loadingFailed(let error):
                    let userInfo = ["error":error]
                    self.handleLoadingFailed(userInfo)
                case .productNotAvailable(let error):
                    let userInfo = ["error":error]
                    self.handleProductNotAvailable(userInfo)
                default:
                    break
                }
            })
        })
    }
    
    fileprivate func update(_ updatedProduct: FoodProduct) {
        // only update the updated product
        // need to find it first in the history.
        var index = 0
        for fetchResult in fetchResultList {
            if let validFetchResult = fetchResult {
                switch validFetchResult {
                case .success(let product):
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
            } 
        }
    }
    
    func flushImages() {
        for fetchResult in fetchResultList {
            if let validFetchResult = fetchResult {
                switch validFetchResult {
                case .success(let product):
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

// Notification definitions

extension Notification.Name {
    static let ProductNotAvailable = Notification.Name("OFFProducts.Notification.Product Not Available")
    static let ProductLoaded = Notification.Name("OFFProducts.Notification.Product Loaded")
    static let FirstProductLoaded = Notification.Name("OFFProducts.Notification.First Product Loaded")
    static let HistoryIsLoaded = Notification.Name("OFFProducts.Notification.History Is Loaded")
    static let ProductUpdated = Notification.Name("OFFProducts.Notification.Product Updated")
    static let ProductLoadingError = Notification.Name("OFFProducts.Notification.Product Loading Error")
}


