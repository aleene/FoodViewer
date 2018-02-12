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
    
    var list = ProductsTab.recent {
        didSet {
            // reload if there is a change of tabs
            if list != oldValue {
                setCurrentProducts()
            }
        }
    }
    
    
    var mostRecentProduct = MostRecentProduct()

    //  Contains all the fetch results for all product types
    private var allProductFetchResultList: [ProductFetchStatus] = []
    
    // Contains all the search fetch results
    private var allSearchFetchResultList: [ProductFetchStatus] = []
    
    // This list contains the product fetch results for the current product type
    //TODO: - make this a fixed variable that is changed when something is added to the allProductFetchResultList
    private var fetchResultList: [ProductFetchStatus] = []
    
    func fetchResult(at index: Int) -> ProductFetchStatus? {
        guard index >= 0 && index < count else { return nil }
        return fetchResultList[index]
    }
    
    func loadProduct(at index: Int) -> ProductFetchStatus? {
        guard index >= 0 && index < count else { return nil }
        loadProductRange(around: index)
        return fetchResultList[index]
    }

    var count: Int {
        return fetchResultList.count
    }
    
    private func loadProductRange(around index: Int) {
        let range = 5
        let lowerBound = index - Int(range/2) < 0 ? 0 : index - Int(range/2)
        let upperBound = index + Int(range/2) < count ? index + Int(range/2) : count - 1
        for ind in lowerBound...upperBound {
            fetchHistoryProduct(at: ind)
        }
    }
    
    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }
    
    private func setCurrentProducts() {
        var list: [ProductFetchStatus] = []
        switch self.list {
        case .recent:
            for fetchResult in allProductFetchResultList {
                switch fetchResult {
                case .success(let product):
                    if let producttype = product.type?.rawValue {
                        if producttype == currentProductType.rawValue {
                            list.append(fetchResult)
                        }
                    }
                default:
                    list.append(fetchResult)
                }
            }
            // If there is nothing on the list add the sample product
            if list.isEmpty {
                loadSampleProduct()
                list.append(sampleProductFetchStatus)
            }
        case .search:
            // show the search query as the first product in the search results
            if let validQuery = searchQuery {
                list.append(.searchQuery(validQuery))
            } else {
                // setup the first product, without a previous search defined
                // with an empty searchQueryProduct
                searchQuery = SearchTemplate()
                if let validSearchQuery = searchQuery {
                    list.append(.searchQuery(validSearchQuery))
                }
            }
            
            // add the search results
            for fetchResult in allSearchFetchResultList {
                switch fetchResult {
                case .success(let product):
                    if let producttype = product.type?.rawValue {
                        if producttype == currentProductType.rawValue {
                            list.append(fetchResult)
                        }
                    }
                case .searchLoading:
                    list.append(.searchLoading)
                case .more(let pageNumber):
                    list.append(.more(pageNumber))
                default: break
                }
            }
        }
        self.fetchResultList = list
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
    
    func resetCurrentProducts() {
        setCurrentProducts()
    }
    
    var sampleProductFetchStatus: ProductFetchStatus = .productNotLoaded( FoodProduct(with:  BarcodeType(value:"whatToPutHere?")))
    
    private func loadSampleProduct() {
        // If the user runs for the first time, then there is no history available
        // Then a sample product will be shown, which is stored with the app
        // historyLoadCount = nil
        switch sampleProductFetchStatus {
        case .productNotLoaded(let product):
            sampleProductFetchStatus = ProductFetchStatus.loading(product)
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
                let fetchResult = OpenFoodFactsRequest().fetchSampleProduct()
                DispatchQueue.main.async(execute: { () -> Void in
                    self.sampleProductFetchStatus = fetchResult
                    self.setCurrentProducts()
                    switch fetchResult {
                    case .success:
                        self.loadSampleImages()
                        NotificationCenter.default.post(name: .FirstProductLoaded, object:nil)
                    case .loadingFailed(let product, let error),
                         .productNotAvailable(let product, let error):
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
    
    func loadSampleImages() {

        // The images are read from the assets catalog as UIImage
        // this ensure that the right resolution will be read
        // and then they are internally stored as PNG data
        /*
        // I need to find where the demo product is.
        if let validFetchResult = allProductFetchResultList[0] {
            switch validFetchResult {
            case .success(let sampleProduct):
                let languageCode = sampleProduct.primaryLanguageCode ?? "en"
                
                if let image = UIImage(named: "SampleMain") {
                    if let data = UIImagePNGRepresentation(image) {
                        sampleProduct.frontImages?.small[languageCode]?.fetchResult = .success(data)
                        sampleProduct.frontImages?.display[languageCode]?.fetchResult = .success(data)
                    }
                } else {
                    sampleProduct.frontImages?.small[languageCode]?.fetchResult = .noData
                    sampleProduct.frontImages?.display[languageCode]?.fetchResult = .noData
                }
                
                if let image = UIImage(named: "SampleIngredients") {
                    if let data = UIImagePNGRepresentation(image) {
                        sampleProduct.ingredientsImages?.small[languageCode]?.fetchResult = .success(data)
                    }
                } else {
                    sampleProduct.ingredientsImages?.small[languageCode]?.fetchResult = .noData
                }
                
                if let image = UIImage(named: "SampleNutrition") {
                    if let data = UIImagePNGRepresentation(image) {
                        sampleProduct.nutritionImages?.small[languageCode]?.fetchResult = .success(data)
                    }
                } else {
                    sampleProduct.nutritionImages?.small[languageCode]?.fetchResult = .noData
                }
                
                sampleProduct.nameLanguage["en"] = NSLocalizedString("Sample Product for Demonstration, the globally known M&M's", comment: "Product name of the product shown at first start")
                sampleProduct.genericNameLanguage["en"] = NSLocalizedString("This sample product shows you how a product is presented. Slide to the following pages, in order to see more product details. Once you start scanning barcodes, you will no longer see this sample product.", comment: "An explanatory text in the common name field.")
                
            default: break
            }
        }
         */
    }
    
    fileprivate func initList() {
        // I need a nillified list of the correct size, because I want to access items through the index.
        if allProductFetchResultList.isEmpty {
            for index in 0..<storedHistory.barcodeTuples.count {
                allProductFetchResultList.append(.productNotLoaded(FoodProduct(with:BarcodeType(value: storedHistory.barcodeTuples[index].0))))
            }
        }
    }
    
    func removeAll() {
            storedHistory = History()
            allProductFetchResultList = []
            loadSampleProduct()
    }
    
    var storedHistory = History()

    fileprivate func fetchHistoryProduct(at index: Int) {
        // guard index >= 0 && index < count else { return }
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

    /*
    // This function manages the loading of the history products. A load batch is never larger than 5 simultaneous threads
    fileprivate var historyLoadCount: Int? = nil {
        didSet {
            if let currentLoadHistory = historyLoadCount {
                let batchSize = 5
                if currentLoadHistory == storedHistory.barcodeTuples.count - 1 {
                    // all products have been loaded from history
                    NotificationCenter.default.post(name: .ProductLoaded, object:nil)
                } else if (currentLoadHistory >= 4) && ((currentLoadHistory + 1 ) % batchSize == 0) {
//NotificationCenter.default.post(name: .ProductLoaded, object:nil)
                    // load next batch
                    let startIndex = currentLoadHistory + 1 <= storedHistory.barcodeTuples.count - 1 ? currentLoadHistory + 1 : storedHistory.barcodeTuples.count - 1
                    let endIndex = startIndex + batchSize - 1 <= storedHistory.barcodeTuples.count - 1 ? startIndex + batchSize - 1 : storedHistory.barcodeTuples.count - 1
                    for index in startIndex...endIndex {
                        fetchHistoryProduct(at:index)
                    }
                } else if currentLoadHistory == 0 {
                    // the first product is already there, so can be shown
                    // NotificationCenter.default.post(name:  .FirstProductLoaded, object:nil)
                    // load first batch up to product 4
                    let startIndex = 1 <= storedHistory.barcodeTuples.count ? 1 : storedHistory.barcodeTuples.count - 1
                    let endIndex = startIndex + batchSize - 1 <= storedHistory.barcodeTuples.count - 1 ? batchSize - 1 : storedHistory.barcodeTuples.count - 1
                    for index in startIndex...endIndex {
                        // print(storedHistory.barcodeTuples[index].1, currentProductType.rawValue)
                        fetchHistoryProduct(at:index)
                    }
                }
            }
        }
    }
  */

    func fetchProduct(_ barcode: BarcodeType?) -> Int? {
        if let validBarcode = barcode {
            // is the product already fetched?
            if let validIndex = index(validBarcode) {
                return validIndex
            } else {
                // retrieve this new product
                let request = OpenFoodFactsRequest()
                DispatchQueue.main.async(execute: { () -> Void in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                })
                // loading the product from internet will be done off the main queue
                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
                    let fetchResult = request.fetchProductForBarcode(validBarcode)
                    DispatchQueue.main.async(execute: { () -> Void in
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        switch fetchResult {
                        case .success(let newProduct):
                        // add product barcode to history
                            self.allProductFetchResultList.insert(fetchResult, at:0)
                            self.setCurrentProducts()
                            // try to get the product type out the json
                            self.storedHistory.add((newProduct.barcode.asString, newProduct.type?.rawValue ?? self.currentProductType.rawValue) )
                            // self.loadMainImage(newProduct)
                            self.saveMostRecentProduct(barcode!)
                            NotificationCenter.default.post(name: .FirstProductLoaded, object:nil)
                        case .loadingFailed(let product, let error),
                             .productNotAvailable(let product, let error):
                            self.allProductFetchResultList.insert(fetchResult, at:0)
                            self.setCurrentProducts()
                            let userInfo = [Notification.ErrorKey:error,
                                            Notification.BarcodeKey:product.barcode.asString]
                            self.handleLoadingFailed(userInfo)
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
    
    func search(_ string: String?, in category: SearchComponent) {
        guard string != nil else { return }
        let validString = string!.contains(":") ?
            string!.split(separator:":").map(String.init)[1] : string!
        list = .search
        search = (category, validString)
    }
    

    private func isProductinList(_ barcode: BarcodeType) -> Int? {
        for (index, fetchResult) in allProductFetchResultList.enumerated() {
            switch fetchResult {
            case .success(let product):
                if product.barcode.asString == barcode.asString {
                    return index
                }
            default:
                break
            }
        }
        return nil
    }
    
    func index(_ barcode: BarcodeType?) -> Int? {
        guard barcode != nil else { return nil }
        for (index, fetchResult) in fetchResultList.enumerated() {
            switch fetchResult {
            case .success(let product):
                if product.barcode.asString == barcode!.asString {
                    return index
                }
            default:
                break
            }
        }
        return nil

    }
    
    func saveMostRecentProduct(_ barcode: BarcodeType?) {
        if let validBarcode = barcode {
            let request = OpenFoodFactsRequest()
            DispatchQueue.main.async(execute: { () -> Void in
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            })
            // loading the product from internet will be done off the main queue
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
                let fetchResult = request.fetchJsonForBarcode(validBarcode)
                DispatchQueue.main.async(execute: { () -> Void in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    switch fetchResult {
                    case .success(let newData):
                        // This will store the data in the user defaults file
                        self.mostRecentProduct.addMostRecentProduct(newData)
                    case .error(let error):
                        let userInfo = [Notification.ErrorKey:error,
                                        Notification.BarcodeKey:validBarcode.asString]
                        self.handleLoadingFailed(userInfo)
                    }
                })
            })
        }
    }
//
// MARK: - Create notifications
//
    func handleProductNotAvailable(_ userInfo: [String:String]) {
        NotificationCenter.default.post(name: .ProductNotAvailable, object:nil, userInfo: userInfo)
    }

    func handleLoadingFailed(_ userInfo: [String:String]) {
        NotificationCenter.default.post(name: .ProductLoadingError, object:nil, userInfo: userInfo)
    }

    fileprivate func isProductInList(_ newBarcode: BarcodeType) -> Int? {
        for (index, fetchResult) in allProductFetchResultList.enumerated() {
            switch fetchResult {
            case .success(let product):
                if product.barcode.asString == newBarcode.asString {
                    return index
                }
            default:
                break
            }
        }
        return nil
    }
    
    func reload(_ product: FoodProduct) {
        let request = OpenFoodFactsRequest()
        var fetchResult = ProductFetchStatus.loading(product)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
            // loading the product from internet will be done off the main queue
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
            fetchResult = request.fetchProductForBarcode(product.barcode)
            DispatchQueue.main.async(execute: { () -> Void in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                switch fetchResult {
                case .success(let newProduct):
                    self.update(newProduct)
                    // encode barcode
                    var userInfo: [String:Any] = [:]
                    userInfo[Notification.BarcodeKey] = newProduct.barcode.asString
                    NotificationCenter.default.post(name: .ProductUpdated, object:nil, userInfo: userInfo)
                case .loadingFailed(let product, let error),
                     .productNotAvailable(let product, let error):
                    let userInfo = [Notification.ErrorKey:error,
                                    Notification.BarcodeKey:product.barcode.asString]
                    self.handleLoadingFailed(userInfo)
                default:
                    break
                }
            })
        })
    }
    
    func reloadAll() {
        // allProductFetchResultList = []
        // get the latest history file
        // storedHistory = History()
        sampleProductFetchStatus = .initialized
        // reset the current list of products
        // the product type might have changed
        setCurrentProducts()
        // historyLoadCount = nil
        loadAll()
    }
    
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
                    NotificationCenter.default.post(name: .FirstProductLoaded, object:nil)
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
    
    // private var searchQueryProduct: FoodProduct? = nil
    
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
    
    private var currentSearchPage: Int = 0
    
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
    
    func flushImages() {
        print("OFFProducts.flushImages - flushing")
        for fetchResult in allProductFetchResultList {
            switch fetchResult {
            case .success(let product):
                product.nutritionImages.removeAll()
                product.frontImages.removeAll()
                product.ingredientsImages.removeAll()
                product.images.removeAll()
            default:
                break
            }
        }
    }
}

// Notification definitions

extension Notification.Name {
    static let ProductNotAvailable = Notification.Name("OFFProducts.Notification.ProductNotAvailable")
    static let ProductLoaded = Notification.Name("OFFProducts.Notification.ProductLoaded")
    static let SearchStarted = Notification.Name("OFFProducts.Notification.SearchStarted")
    static let SearchLoaded = Notification.Name("OFFProducts.Notification.SearchLoaded")
    static let FirstProductLoaded = Notification.Name("OFFProducts.Notification.FirstProductLoaded")
    static let HistoryIsLoaded = Notification.Name("OFFProducts.Notification.HistoryIsLoaded")
    static let ProductUpdated = Notification.Name("OFFProducts.Notification.ProductUpdated")
    static let ProductLoadingError = Notification.Name("OFFProducts.Notification.ProductLoadingError")
}


