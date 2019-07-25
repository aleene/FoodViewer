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
    // The use of a singleton limits thus the number of file loads
    
    internal struct Notification {
        static let BarcodeDoesNotExistKey = "OFFProducts.Notification.BarcodeDoesNotExist.Key"
        //static let SearchStringKey = "OFFProducts.Notification.SearchString.Key"
        //static let SearchOffsetKey = "OFFProducts.Notification.SearchOffset.Key"
        //static let SearchPageKey = "OFFProducts.Notification.SearchPage.Key"
        static let BarcodeKey = "OFFProducts.Notification.Barcode.Key"
        static let ErrorKey = "OFFProducts.Notification.Error.Key"
    }
    
    static let manager = OFFProducts()
    
    // The index of the latest product that was added (scanned or typed)
    var currentScannedProduct: Int? = nil
    
    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }
    
    init() {
        // Initialize the products, multiple options are possible:
        // - there is no history, the user usese the app the first time for instance -> show a sample product
        // - there are products in the history file
        //      check first if the most recent product has been stored and load that one
        //      then load the rest of the history products
        loadAll()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    //  Contains all the fetch results for all product types
    private var allProductPairs: [ProductPair] = []
    
    private var productPairList: [ProductPair] = []
    
    private func loadAll() {
        if allProductPairs.isEmpty {
            let storedList = storedHistory.barcodes(for: currentProductType)
            // If there is no history, we are in the cold start case
            if !storedList.isEmpty {
                // create all productPairs found in the history
                storedList.forEach({
                    allProductPairs.append( ProductPair( barcodeString: $0, type: currentProductType))
                })
                // load the most recent stored product
                allProductPairs[0].localStatus = .loading( allProductPairs[0].barcodeType.asString )
                MostRecentProduct().load() { (product: FoodProduct?) in
                    if let validProduct = product {
                        self.allProductPairs[0].localProduct = product
                        self.allProductPairs[0].barcodeType = BarcodeType.mostRecent(validProduct.barcode.asString, validProduct.type)
                        self.allProductPairs[0].updateIsAllowed = true
                    }
                }
                loadProductPairRange(around: 0)
            } else {
                // The cold start case when the user has not yet used the app
                loadSampleProductPair()
            }
        }
        // define the public set of products
        setCurrentProductPairs()
    }

    var count: Int {
        return productPairList.count
    }
    
    func resetCurrentProductPairs() {
        setCurrentProductPairs()
    }

    private func setCurrentProductPairs() {
        var list: [ProductPair] = []
        for productPair in allProductPairs {
            // TODO: Is this needed? The idea is to only selectd the right productType,
            // but do I not already know that?
            switch productPair.remoteStatus {
               case .available:
                if let producttype = productPair.remoteProduct?.type?.rawValue {
                    if producttype == currentProductType.rawValue {
                        list.append(productPair)
                    }
                }
            default:
                list.append(productPair)
            }
        }
        // If there is nothing on the list add the sample product
        if list.isEmpty {
            //loadSampleProductPair()
            // TODO: Must be for the type!!!!
            //list.append(sampleProductPair)
        }
        self.productPairList = list
    }

    private func loadProductPairRange(around index: Int) {
        let range = 8
        let lowerBound = index - Int(range/2) < 0 ? 0 : index - Int(range/2)
        let upperBound = index + Int(range/2) < allProductPairs.count ? index + Int(range/2) : allProductPairs.count - 1
        for ind in lowerBound...upperBound {
            allProductPairs[ind].preFetch()
        }
    }
    
    func removeAllProductPairs() {
        storedHistory = History()
        allProductPairs = []
        loadSampleProductPair()
    }

//
//  MARK: ProductPair Element Functions
//
    func productPair(at index: Int) -> ProductPair? {
        guard index >= 0 && index < count else { return nil }
        return productPairList[index]
    }
    
    @discardableResult
    func loadProductPair(at index: Int) -> ProductPair? {
        guard index >= 0 && index < count else { return nil }
        loadProductPairRange(around: index)
        return productPairList[index]
    }
    
    func productPair(for barcode: BarcodeType) -> ProductPair? {
        if let index = indexOfProductPair(with: barcode){
            return productPair(at: index)
        }
        return nil
    }
    
    func indexOfProductPair(with barcodeType: BarcodeType?) -> Int? {
        guard let validbarcodeType = barcodeType else { return nil }
        return allProductPairs.firstIndex(where: { $0.barcodeType.asString == validbarcodeType.asString })
    }
    
    func index(of productPair: ProductPair?) -> Int? {
        guard let validProductPair = productPair else { return nil }
        return allProductPairs.firstIndex(where: { $0.barcodeType.asString == validProductPair.barcodeType.asString })
    }
    
    func createProduct(with barcodeType: BarcodeType) -> Int {
        if let existingIndex = indexOfProductPair(with: barcodeType) {
            // check if the product does not exist
            return existingIndex
        }
        // The product does not exist yet.
        
        // if the first one is a sample product remove it
        if allProductPairs.count == 1 {
            switch allProductPairs[0].barcodeType {
            case .sample:
                allProductPairs = []
            default:
                break
            }
        }
        // Create the productPair
        allProductPairs.insert(ProductPair(barcodeType: barcodeType), at: 0)
        // and start fetching
        allProductPairs[0].newFetch()
        // save the new product as the most recent one
        MostRecentProduct().save(product:allProductPairs[0].remoteProduct)
        // save the new product in the history
        storedHistory.add(barcodeType: allProductPairs[0].barcodeType )
        
        // recalculate the productPairs
        setCurrentProductPairs()
        // Inform the viewControllers that the product list is larger
        let userInfo = [Notification.BarcodeKey: allProductPairs[0].barcodeType.asString]
        NotificationCenter.default.post(name: .ProductListExtended, object:nil, userInfo: userInfo)
        return 0
    }
    
    func createProductPair(with barcodeType: BarcodeType) -> ProductPair? {
        // get the index of the existing productPair
        if let validIndex = indexOfProductPair(with: barcodeType) {
            currentScannedProduct = validIndex
            loadProductPair(at: validIndex)
            return productPair(at: validIndex)
        } else {
            let validIndex = createProduct(with: barcodeType)
            // create a new productPair
            currentScannedProduct = validIndex
            loadProductPair(at: validIndex)
            return productPair(at: validIndex)
        }
    }
    
    func fetchProduct(with barcodeType: BarcodeType) {
        if let index = indexOfProductPair(with: barcodeType) {
            // The product exists
            allProductPairs[index].newFetch()
        }
    }

    private func loadSampleProductPair() {
        Sample().load() { (product: FoodProduct?) in
            if let validProduct = product {
                let productPair = ProductPair(product: validProduct)
                productPair.updateIsAllowed = false
                self.allProductPairs.append(productPair)
                self.setCurrentProductPairs()
                NotificationCenter.default.post(name: .FirstProductLoaded, object:nil)
            }
            // I could add a notification here to inform the vc.
            // However the vc is not loaded yet, so it can not receive anything.
        }
    }

    var storedHistory = History()

    /*
    // does not have to be copied for productPairs
    fileprivate func fetchHistoryProduct(at index: Int) {
        guard index >= 0 && index < count else { return }
        // only fetch if we do not started the loading yet
        switch allProductFetchResultList[index] {
        case .productNotLoaded(let product),
             .loadingFailed(let product, _):
            allProductFetchResultList[index] = .loading(product)
            let request = OpenFoodFactsRequest()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            // loading the product from internet will be done off the main queue
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
                let fetchResult = request.fetchProductForBarcode(BarcodeType.init(value: product.barcode.asString))
                DispatchQueue.main.async(execute: { () -> Void in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.allProductFetchResultList[index] = fetchResult
                    self.setCurrentProducts()
                    switch fetchResult {
                    case .success(let product):
                        //if self.historyLoadCount != nil {
                            //self.historyLoadCount! += 1
                            var userInfo: [String:Any] = [:]
                            userInfo[Notification.BarcodeKey] = product.barcode.asString
                            NotificationCenter.default.post(name: .ProductLoaded, object:nil, userInfo: userInfo)
                        //}
                    case .loadingFailed(let product, let error),
                         .productNotAvailable(let product, let error):
                        //self.historyLoadCount! += 1
                        let userInfo = [Notification.ErrorKey:error,
                                        Notification.BarcodeKey:product.barcode.asString]
                        self.handleLoadingFailed(userInfo)
                    default: break
                    }
                })
            })
        default:
            break
        }
    }
  */
    
    //TODO: This can be replaced with the JSON encoder
    
    func reload(productPair: ProductPair?) {
        productPair?.reload()
    }
    
    func reloadAll() {
        //sampleProductFetchStatus = .initialized
        // reset the current list of products
        allProductPairs = []
        loadAll()
    }
    
    /*
    private func loadAll() {
        switch list {
        case .recent:
            if allProductFetchResultList.isEmpty {
                // If there is no history, we are in the cold start case
                if !storedHistory.barcodeTuples.isEmpty {
                    initList()
                    // load the most recent product from the local storage
                    if let data = mostRecentProduct.jsonData {
                        var fetchResult = ProductFetchStatus.initialized
                        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
                            fetchResult = OpenFoodFactsRequest().fetchStoredProduct(data)
                            DispatchQueue.main.async(execute: { () -> Void in
                                switch fetchResult {
                                case .success(let product):
                                    // the stored product might not correspond to the first product in the history
                                    // so it should be stored in the right spot
                                    if let index = self.storedHistory.index(for:product.barcode) {
                                        self.allProductFetchResultList[index] = fetchResult
                                        self.setCurrentProducts()
                                        NotificationCenter.default.post(name: .FirstProductLoaded, object:nil)
                                    } else {
                                        print("OFFProducts - stored product not in history file")
                                    }
                                case .loadingFailed(let product, let error):
                                    let userInfo = [Notification.ErrorKey:error,
                                                    Notification.BarcodeKey:product.barcode.asString]
                                    self.handleLoadingFailed(userInfo)
                                case .productNotAvailable:
                                    // if the product is not available there is an error in storage
                                    // and can be removed
                                    self.mostRecentProduct.removeForCurrentProductType()
                                    // let userInfo = ["error":error]
                                // self.handleProductNotAvailable(userInfo)
                                default: break
                                }
                                //self.historyLoadCount = 0
                                //self.historyLoadCount! += 1
                            })
                        })
                    } else {
                        // the data is not available
                        // has to be loaded from the OFF-servers
                        _ = fetchProduct(BarcodeType(value: storedHistory.barcodeTuples[0].0))
                        //historyLoadCount = 0
                    }
                } else {
                    // The cold start case when the user has not yet used the app
                    loadSampleProduct()
                    //NotificationCenter.default.post(name: .FirstProductLoaded, object:nil)
                }
            } else {
                setCurrentProducts()
                NotificationCenter.default.post(name: .ProductLoaded, object:nil)
            }
        case .search:
            // Has a search been setup?
            if searchQuery != nil {
                startFreshSearch()
            } else {
                setCurrentProducts()
                if allSearchFetchResultList.count > 0 {
                    let userInfo = [Notification.SearchStringKey:"NO SEARCH"]
                    NotificationCenter.default.post(name: .SearchLoaded, object:nil, userInfo: userInfo)
                }
            }
            
        }
    }
  */
    
    let pendingOperations = PendingOperations()

    func deselectImage(for productPair: ProductPair, in languageCode: String, of imageTypeCategory: ImageTypeCategory) {
        // loop over all operations needed to upload a product
        for (key, operation) in productPair.deselect(languageCode, of: imageTypeCategory) {
            //1 - if the operation already exists do not add it again and move to the next operation
            if pendingOperations.uploadsInProgress[key] == nil {
            
                //3
                operation.completionBlock = {
                if operation.isCancelled {
                    return
                }
                // the operation is finished, it can be removed from the uploads in progress
                self.pendingOperations.uploadsInProgress.removeValue(forKey: key)
            }
            
            //4
            pendingOperations.uploadsInProgress[key] = operation
            
            //5
            pendingOperations.uploadQueue.addOperation(operation)
        }
        }
    }

    func startUpload(for productPair: ProductPair) {
        
        // loop over all operations needed to upload a product
        for (key, operation) in productPair.uploadOperationsDict() {
            
            //1 - if the operation already exists do not add it again and move to the next operation
            if pendingOperations.uploadsInProgress[key] == nil {
                
                //3
                operation.completionBlock = {
                    if operation.isCancelled {
                        return
                    }
                    // the operation is finished, it can be removed from the uploads in progress
                    self.pendingOperations.uploadsInProgress.removeValue(forKey: key)
                }
                
                //4
                pendingOperations.uploadsInProgress[key] = operation
                
                //5
                pendingOperations.uploadQueue.addOperation(operation)
            }
        }
        
    }
    
    func flushImages() {
        print("OFFProducts.flushImages - flushing")
        self.allProductPairs.forEach({ $0.flushImages() })
    }
    
}

// Notification definitions

extension Notification.Name {
    static let ProductListExtended = Notification.Name("OFFProducts.Notification.ProductListExtended")
    static let ProductNotAvailable = Notification.Name("OFFProducts.Notification.ProductNotAvailable")
    static let FirstProductLoaded = Notification.Name("OFFProducts.Notification.FirstProductLoaded")
    static let HistoryIsLoaded = Notification.Name("OFFProducts.Notification.HistoryIsLoaded")
    static let ProductLoadingError = Notification.Name("OFFProducts.Notification.ProductLoadingError")
}


