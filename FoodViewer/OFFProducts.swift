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
        static let SearchStringKey = "OFFProducts.Notification.SearchString.Key"
        static let SearchOffsetKey = "OFFProducts.Notification.SearchOffset.Key"
        static let SearchPageKey = "OFFProducts.Notification.SearchPage.Key"
        static let BarcodeKey = "OFFProducts.Notification.Barcode.Key"
        static let ErrorKey = "OFFProducts.Notification.Error.Key"
    }
    
    static let manager = OFFProducts()
    
    enum ProductsTab {
        case recent
        case search
    }
    
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

    var list = ProductsTab.recent {
        didSet {
            // reload if there is a change of tabs
            if list != oldValue {
                setCurrentProductPairs()
            }
        }
    }

    //  Contains all the fetch results for all product types
    private var allProductPairs: [ProductPair] = []
    
    // Contains all the search fetch results
    private var allSearchPairs: [ProductPair] = []
    
    // This list contains the product fetch results for the current product type
    //TODO: - make this a fixed variable that is changed when something is added to the allProductFetchResultList
    private var productPairList: [ProductPair] = []
    
    private func loadAll() {
        switch list {
        case .recent:
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
            
        case .search:
            // Has a search been setup?
            if searchQuery != nil {
                startFreshSearch()
            } else {
                setCurrentProductPairs()
                if allSearchPairs.count > 0 {
                    let userInfo = [Notification.SearchStringKey:"NO SEARCH"]
                    NotificationCenter.default.post(name: .SearchLoaded, object:nil, userInfo: userInfo)
                }
            }
            
        }
    }

    var count: Int {
        return productPairList.count
    }
    
    func resetCurrentProductPairs() {
        setCurrentProductPairs()
    }

    private func setCurrentProductPairs() {
        var list: [ProductPair] = []
        switch self.list {
        case .recent:
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
        case .search:
            // show the search query as the first product in the search results
            if let validQuery = searchQuery {
                let searchProductPair = ProductPair.init(barcodeType: BarcodeType(barcodeString: "Search Template", type: Preferences.manager.showProductType))
                searchProductPair.searchTemplate = validQuery
                list.append(searchProductPair)
            } else {
                // setup the first product, without a previous search defined
                // with an empty searchQueryProduct
                searchQuery = SearchTemplate()
                if let validSearchQuery = searchQuery {
                    let searchProductPair = ProductPair.init(barcodeType: BarcodeType(barcodeString: "Empty Search Template", type: Preferences.manager.showProductType))
                    searchProductPair.searchTemplate = validSearchQuery
                    list.append(searchProductPair)
                }
            }
            
            // add the search results
            for searchPair in allSearchPairs {
                list.append(searchPair)
            }
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
        return allProductPairs.index(where: { $0.barcodeType.asString == validbarcodeType.asString })
    }
    
    func index(of productPair: ProductPair?) -> Int? {
        guard let validProductPair = productPair else { return nil }
        return allProductPairs.index(where: { $0.barcodeType.asString == validProductPair.barcodeType.asString })
    }
    
    func createProduct(with barcodeType: BarcodeType) -> Int {
        if let existingIndex = indexOfProductPair(with: barcodeType) {
            // check if the product does not exist
            return existingIndex
        }
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
    
    // This function inserts a new ProductPair in the current list, in the history and as most recent product
    /*
    func insertProductPair(_ barcode: BarcodeType?) -> Int? {
        if let validBarcode = barcode {
            // is the product already fetched?
            if let validIndex = productPairIndex(validBarcode) {
                return validIndex
            } else {
                let newProductPair = ProductPair.init(barcodeType: validBarcode)
                newProductPair.fetch()
                // add product barcode to history
                self.allProductPairs.insert(newProductPair, at: 0)
                self.setCurrentProductPairs()
                // try to get the product type out the json
                self.storedHistory.add( (newProductPair.barcodeType.asString, newProductPair.type.rawValue) )
                // self.loadMainImage(newProduct)
                self.saveMostRecentProduct(barcode!)
            }
        }
        return nil
    }
  */

    
    func search(_ string: String?, in category: SearchComponent) {
        guard string != nil else { return }
        let validString = string!.contains(":") ?
            string!.split(separator:":").map(String.init)[1] : string!
        list = .search
        search = (category, validString)
    }

    /*
    func removeProduct(with barcodeType:BarcodeType) {
        if let validIndex = productPairIndex(barcodeType) {
            allProductPairs.remove(at: validIndex)
        }
        storedHistory.remove(barcodeType)
        // recalculate the productPairs
        setCurrentProductPairs()
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
//
// MARK: - Search Specific functions and variables
//
    // no search has been set at the start
    var search: (SearchComponent?, String?)? = nil {
        didSet {
            if search != nil {
                createSearchQuery()
                loadAll()
            }
        }
    }
    
    func startSearch() {
        if searchQuery != nil {
            // searchQueryProduct = product
            loadAll()
        }
    }
        
    var searchQuery: SearchTemplate? = nil
    
    private func createSearchQuery() {
        if let validSearch = search,
            let validComponent = validSearch.0,
            let validString = validSearch.1 {
            searchQuery = SearchTemplate(for:validString, in:validComponent)
            // Define the product as a search product of current product type
            // searchQueryProduct?.barcode = .search("", OFFProducts.manager.currentProductType)
        } else {
            searchQuery = nil
        }
    }
    
    var searchResultSize: Int? = nil

    private func startFreshSearch() {
        if let validQuery = searchQuery {
            if !validQuery.isEmpty {
                // let validSearchString = validSearchPairs[0].1
                // reset search page
                currentSearchPage = 0
                allSearchPairs = []
                allSearchPairs.append(ProductPair(remoteStatus: .searchLoading, type: Preferences.manager.showProductType))
                setCurrentProductPairs()
                // send a notification to inform that a search has started
                let userInfo: [String:Any] = [Notification.SearchStringKey:"Search Defined",
                                              Notification.SearchPageKey:currentSearchPage]
                NotificationCenter.default.post(name: .SearchStarted, object:nil, userInfo: userInfo)
                
                fetchSearchProductsForNextPage()
            } else {
                allSearchPairs = []
            }
            setCurrentProductPairs()
        }
    }
    /*
    private func startFreshSearch() {
        if let validQuery = searchQuery {
            if !validQuery.isEmpty {
                // let validSearchString = validSearchPairs[0].1
                // reset search page
                currentSearchPage = 0
                allSearchFetchResultList = []
                allSearchFetchResultList.append(.searchLoading)
                setCurrentProducts()
                // send a notification to inform that a search has started
                let userInfo: [String:Any] = [Notification.SearchStringKey:"Search Defined",
                                                  Notification.SearchPageKey:currentSearchPage]
                NotificationCenter.default.post(name: .SearchStarted, object:nil, userInfo: userInfo)
                    
                fetchSearchProductsForNextPage()
            } else {
                allSearchFetchResultList = []
            }
            setCurrentProducts()
        }
    }
    */
    private var currentSearchPage: Int = 0
    
    public func fetchSearchProductsForNextPage() {
        if let validQuery = searchQuery {
            if !validQuery.isEmpty {
                //let validSearchComponent = validSearchPairs[0].0
                //let validSearchValue = validSearchPairs[0].1
                currentSearchPage += 1
                if allSearchPairs.isEmpty {
                    allSearchPairs.append(ProductPair(remoteStatus: .searchLoading, type: Preferences.manager.showProductType))
                } else {
                    if let lastItem = allSearchPairs.last?.remoteStatus {
                        switch lastItem {
                        case .more:
                            allSearchPairs[allSearchPairs.count - 1].remoteStatus = .searchLoading
                        default:
                            break
                        }
                    }
                }
                setCurrentProductPairs()
                // send a notification to inform that a search has started
                let userInfo: [String:Any] = [Notification.SearchStringKey:"Search set",
                                          Notification.SearchPageKey:currentSearchPage]
                NotificationCenter.default.post(name: .SearchStarted, object:nil, userInfo: userInfo)
            
                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
                    let fetchResult = OpenFoodFactsRequest().fetchProducts(for:validQuery, on:self.currentSearchPage)
                    DispatchQueue.main.async(execute: { () -> Void in
                    switch fetchResult {
                    case .searchList(let searchResult):
                        // searchResult is a tuple (searchResultSize, pageNumber, pageSize, products for pageNumber)
                        self.searchQuery?.numberOfSearchResults = searchResult.0
                        // is this the first page of a search?
                        if searchResult.1 == 1 {
                            // Then we should restart with an empty product list
                            self.allSearchPairs = []
                            self.currentSearchPage = 1
                            // if the last result in the file is a more instruction remove it
                        } else if let lastSearchPair = self.allSearchPairs.last {
                            switch lastSearchPair.remoteStatus {
                            case .more, .searchLoading:
                                self.allSearchPairs.remove(at: self.allSearchPairs.count - 1)
                            default:
                                break
                            }
                        }
                    
                        // Add the search results to the new product list
                        for product in searchResult.3 {
                            self.allSearchPairs.append(ProductPair(product: product))
                        }
                        // are there more products available?
                        if searchResult.0 > self.allSearchPairs.count + 1 {
                            self.allSearchPairs.append(ProductPair(remoteStatus: .more(searchResult.1 + 1), type: Preferences.manager.showProductType))
                        }
                    
                        self.setCurrentProductPairs()
                        let userInfo: [String:Any] = [Notification.SearchStringKey:"What to put here?",
                                    Notification.SearchOffsetKey:searchResult.1 * searchResult.2]
                        NotificationCenter.default.post(name: .SearchLoaded, object:nil, userInfo: userInfo)
                    case .loadingFailed(let barcodeString),
                         .productNotAvailable(let barcodeString):
                        let userInfo = [Notification.BarcodeKey: barcodeString]
                        NotificationCenter.default.post(name: .ProductLoadingError, object:nil, userInfo: userInfo)
                    case .productNotLoaded(let barcodeString):
                        let userInfo = [Notification.BarcodeKey: barcodeString]
                        NotificationCenter.default.post(name: .ProductLoadingError, object:nil, userInfo: userInfo)
                    default:
                        break
                    }
                })
            })
            }
        }
    }
    
    /*
    public func fetchSearchProductsForNextPage() {
        if let validQuery = searchQuery {
            if !validQuery.isEmpty {
                //let validSearchComponent = validSearchPairs[0].0
                //let validSearchValue = validSearchPairs[0].1
                currentSearchPage += 1
                if allSearchFetchResultList.isEmpty {
                    allSearchFetchResultList.append(.searchLoading)
                } else {
                    if let lastItem = allSearchFetchResultList.last {
                        switch lastItem {
                        case .more:
                            allSearchFetchResultList[allSearchFetchResultList.count - 1] = .searchLoading
                        default:
                            break
                        }
                    }
                }
                setCurrentProducts()
                // send a notification to inform that a search has started
                let userInfo: [String:Any] = [Notification.SearchStringKey:"Search set",
                                              Notification.SearchPageKey:currentSearchPage]
                NotificationCenter.default.post(name: .SearchStarted, object:nil, userInfo: userInfo)
                
                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
                    let fetchResult = OpenFoodFactsRequest().fetchProducts(for:validQuery, on:self.currentSearchPage)
                    DispatchQueue.main.async(execute: { () -> Void in
                        switch fetchResult {
                        case .searchList(let searchResult):
                            // searchResult is a tuple (searchResultSize, pageNumber, pageSize, products for pageNumber)
                            self.searchQuery?.numberOfSearchResults = searchResult.0
                            // is this the first page of a search?
                            if searchResult.1 == 1 {
                                // Then we should restart with an empty product list
                                self.allSearchFetchResultList = []
                                self.currentSearchPage = 1
                                // if the last result in the file is a more instruction remove it
                            } else if let lastFetchResult = self.allSearchFetchResultList.last {
                                switch lastFetchResult {
                                case .more, .searchLoading:
                                    self.allSearchFetchResultList.remove(at: self.allSearchFetchResultList.count - 1)
                                default:
                                    break
                                }
                            }
                            
                            // Add the search results to the new product list
                            for product in searchResult.3 {
                                self.allSearchFetchResultList.append(.success(product))
                            }
                            // are there more products available?
                            if searchResult.0 > self.allSearchFetchResultList.count + 1 {
                                self.allSearchFetchResultList.append(.more(searchResult.1 + 1))
                            }
                            
                            self.setCurrentProducts()
                            let userInfo: [String:Any] = [Notification.SearchStringKey:"What to put here?",
                                                          Notification.SearchOffsetKey:searchResult.1 * searchResult.2]
                            NotificationCenter.default.post(name: .SearchLoaded, object:nil, userInfo: userInfo)
                        case .loadingFailed(let product, let error),
                             .productNotAvailable(let product, let error):
                            let userInfo = [Notification.ErrorKey:error,
                                            Notification.BarcodeKey: product.barcode.asString]
                            self.handleLoadingFailed(userInfo)
                        default: break
                        }
                    })
                })
            }
        }
    }
*/
    /*
    fileprivate func update(_ updatedProduct: FoodProduct) {
        // only update the updated product
        // need to find it first in the history or in the search list.
        var index = 0
        for fetchResult in allProductFetchResultList {
            switch fetchResult {
            case .success(let product):
                if product.barcode.asString == updatedProduct.barcode.asString {
                    // replace the existing product with the data of the new product
                    product.updateDataWith(updatedProduct)
                    // is this the first product in the list
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
        
        for fetchResult in allSearchFetchResultList {
            switch fetchResult {
            case .success(let product):
                if product.barcode.asString == updatedProduct.barcode.asString {
                    // replace the existing product with the data of the new product
                    product.updateDataWith(updatedProduct)
                }
            default:
                break
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
    static let SearchStarted = Notification.Name("OFFProducts.Notification.SearchStarted")
    static let SearchLoaded = Notification.Name("OFFProducts.Notification.SearchLoaded")
    static let FirstProductLoaded = Notification.Name("OFFProducts.Notification.FirstProductLoaded")
    static let HistoryIsLoaded = Notification.Name("OFFProducts.Notification.HistoryIsLoaded")
    static let ProductLoadingError = Notification.Name("OFFProducts.Notification.ProductLoadingError")
}


