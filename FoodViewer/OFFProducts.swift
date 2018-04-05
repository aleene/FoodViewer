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
                // If there is no history, we are in the cold start case
                if !storedHistory.barcodeTuples.isEmpty {
                    // create all productPairs found in the history
                    initProductPairList()
                    if allProductPairs.isEmpty {
                        loadSampleProductPair()
                    }
                    // load the locally stored product
                    allProductPairs[0].localStatus = .loading(allProductPairs[0].barcodeType.asString)
                    MostRecentProduct().load() { (product: FoodProduct?) in
                        if let validProduct = product {
                            self.allProductPairs[0].localProduct = product
                            self.allProductPairs[0].barcodeType = BarcodeType.mostRecent(validProduct.barcode.asString, validProduct.type)
                            self.allProductPairs[0].updateIsAllowed = false
                        }
                        // I could add a notification here to inform the vc.
                        // However the vc is not loaded yet, so it can not receive anything.
                    }
                    loadProductPairRange(around: 0)
                } else {
                    // The cold start case when the user has not yet used the app
                    loadSampleProductPair()
                    NotificationCenter.default.post(name: .FirstProductLoaded, object:nil)
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
                //loadSampleProduct()
                // TODO: Must be for the type!!!!
                list.append(sampleProductPair)
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
        let range = 5
        let lowerBound = index - Int(range/2) < 0 ? 0 : index - Int(range/2)
        let upperBound = index + Int(range/2) < allProductPairs.count ? index + Int(range/2) : allProductPairs.count - 1
        for ind in lowerBound...upperBound {
            allProductPairs[ind].fetch()
        }
    }

    fileprivate func initProductPairList() {
        // I need a nillified list of the correct size, because I want to access items through the index.
        if allProductPairs.isEmpty {
            for index in 0..<storedHistory.barcodeTuples.count {
                // only append the products for the current product type
                if storedHistory.barcodeTuples[index].1 == Preferences.manager.showProductType.rawValue {
                    allProductPairs.append(ProductPair(barcodeString:storedHistory.barcodeTuples[index].0, type:Preferences.manager.showProductType))
                }
            }
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
        if let index = productPairIndex(barcode){
            return productPair(at: index)
        }
        return nil
    }
    
    func productPairIndex(_ barcodeType: BarcodeType?) -> Int? {
        guard barcodeType != nil else { return nil }
        for (index, productPair) in allProductPairs.enumerated() {
            if productPair.barcodeType.asString == barcodeType!.asString {
                return index
            }
        }
        return nil
    }
    
    func indexOfProduct(with barcodeType: BarcodeType) -> Int? {
        if let index = productPairIndex(barcodeType) {
            // The product aleady exists
            return index
        }
        return nil
    }
    
    func createProduct(with barcodeType: BarcodeType) -> Int {
        if let existingIndex = indexOfProduct(with: barcodeType) {
            // check if the product does not exist
            return existingIndex
        }
        // Create the productPair
        allProductPairs.insert(ProductPair(barcodeType: barcodeType), at: 0)
        // and start fetching
        allProductPairs[0].fetch()
        // save the new product as the most recent one
        MostRecentProduct().save(allProductPairs[0].barcodeType)
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
        if let index = productPairIndex(barcodeType) {
            // The product exists
            allProductPairs[index].fetch()
        }
    }

//
// MARK: Product sample functions
//
    
    var sampleProductFetchStatus: ProductFetchStatus = .productNotLoaded( "whatToPutHere?")
    
    var sampleProductPair: ProductPair {
        switch Preferences.manager.showProductType {
        case .beauty:
            return ProductPair.init(barcodeString: "4005900122063", type: .beauty)
        case .food:
            return ProductPair.init(barcodeString: "40111490", type: .food )
        case .petFood:
            return ProductPair.init(barcodeString: "3166780740950", type: .petFood)
        }
    }
    
    private func loadSampleProductPair() {
        allProductPairs.append(sampleProductPair)
    }
    
    /*
    private func loadSampleProduct() {
        // If the user runs for the first time, then there is no history available
        // Then a sample product will be shown, which is stored with the app
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
  */
    
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
        if let validProductPair = productPair {
            validProductPair.fetch()
        }
    }
    
    func reloadAll() {
        sampleProductFetchStatus = .initialized
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

                    default: break
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
    
    func flushImages() {
        print("OFFProducts.flushImages - flushing")
        self.allProductPairs.forEach({ $0.flushImages() })
    }
    
}

// Notification definitions

extension Notification.Name {
    static let ProductListExtended = Notification.Name("OFFProducts.Notification.ProductListExtended")
    static let ProductNotAvailable = Notification.Name("OFFProducts.Notification.ProductNotAvailable")
    //static let ProductLoaded = Notification.Name("OFFProducts.Notification.ProductLoaded")
    static let SearchStarted = Notification.Name("OFFProducts.Notification.SearchStarted")
    static let SearchLoaded = Notification.Name("OFFProducts.Notification.SearchLoaded")
    static let FirstProductLoaded = Notification.Name("OFFProducts.Notification.FirstProductLoaded")
    static let HistoryIsLoaded = Notification.Name("OFFProducts.Notification.HistoryIsLoaded")
    //static let ProductUpdated = Notification.Name("OFFProducts.Notification.ProductUpdated")
    static let ProductLoadingError = Notification.Name("OFFProducts.Notification.ProductLoadingError")
}


