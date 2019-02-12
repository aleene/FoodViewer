//
//  Search.swift
//  FoodViewer
//
//  Created by arnaud on 07/02/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import Foundation

class Search {
    
    internal struct Notification {
        static let SearchStringKey = "OFFSearchProducts.Notification.SearchString.Key"
        static let SearchOffsetKey = "OFFSearchProducts.Notification.SearchOffset.Key"
        static let SearchPageKey = "OFFSearchProducts.Notification.SearchPage.Key"
    }
    
    var query: SearchTemplate? = nil {
        didSet {
            if query != nil {
                status = .notLoaded
            } else {
                status = .initialized
            }
        }
    }
    
    var status: SearchFetchStatus = .initialized
    
    var isDefined: Bool {
        if let count = query?.searchPairsWithArray().count {
            return count > 0
        } else {
            return false
        }
    }
    
    var componentsCount: Int {
        if isDefined {
            return query!.searchPairsWithArray().count
        } else {
            return 0
        }
    }
    
    // Contains all the search fetch results
    var productPairs: [ProductPair] = []
    
    func category(for component:Int) -> String? {
        return query?.searchPairsWithArray()[component].0.description
    }
    
    var sortOrder: SearchSortOrder? {
        return query?.sortOrder
    }

    func label(for component:Int) -> String? {
        return query?.searchPairsWithArray()[component].1.first
    }
    
    func text(for component:Int) -> String? {
        guard query != nil else { return nil }
        switch query!.searchPairsWithArray()[component].0 {
        case .searchText:
            return nil
        default:
            return query!.searchPairsWithArray()[component].2
        }
    }

    
    // initialize with a defined template
    init(query:SearchTemplate) {
        self.query = query
    }
    
    init(for string: String?, in category: SearchComponent) {
        guard string != nil else { return }
        let validString = string!.contains(":") ?
            string!.split(separator:":").map(String.init)[1] : string!
        createSearchQuery(for:(category, validString))
    }

    private func loadAll() {
        // Has a search been setup?
        if query != nil {
            startFreshSearch()
        } else {
           if productPairs.count > 0 {
               let userInfo = [Notification.SearchStringKey:"NO SEARCH"]
              NotificationCenter.default.post(name: .SearchLoaded, object:nil, userInfo: userInfo)
          }
        }
    }
    
    func startSearch() {
        if query != nil {
            // searchQueryProduct = product
            loadAll()
        }
    }
    
    private func createSearchQuery(for tuple:(SearchComponent?, String?)?) {
        if let validSearch = tuple,
            let validComponent = validSearch.0,
            let validString = validSearch.1 {
            query = SearchTemplate(for:validString, in:validComponent)
        } else {
            query = nil
        }
    }
    
    var searchResultSize: Int? = nil
    
    private func startFreshSearch() {
        if let validQuery = query {
            if !validQuery.isEmpty {
                // let validSearchString = validSearchPairs[0].1
                // reset search page
                currentSearchPage = 0
                productPairs = []
                //allSearchPairs.append(ProductPair(remoteStatus: .searchLoading, type: Preferences.manager.showProductType))
                //setCurrentProductPairs()
                // send a notification to inform that a search has started
                let userInfo: [String:Any] = [Notification.SearchStringKey:"Search Defined",
                                              Notification.SearchPageKey:currentSearchPage]
                NotificationCenter.default.post(name: .SearchStarted, object:nil, userInfo: userInfo)
                
                fetchSearchProductsForNextPage()
            } else {
                productPairs = []
            }
            //setCurrentProductPairs()
        }
    }
    
    private var currentSearchPage: Int = 0
    
    public func fetchSearchProductsForNextPage() {
        if let validQuery = query {
            if !validQuery.isEmpty {
                //let validSearchComponent = validSearchPairs[0].0
                //let validSearchValue = validSearchPairs[0].1
                currentSearchPage += 1
                //if allSearchPairs.isEmpty {
                //allSearchPairs.append(ProductPair(remoteStatus: .searchLoading, type: Preferences.manager.showProductType))
                //} else {
                //  if let lastItem = allSearchPairs.last?.remoteStatus {
                //     switch lastItem {
                //     case .more:
                //        allSearchPairs[allSearchPairs.count - 1].remoteStatus = .searchLoading
                //    default:
                //       break
                //  }
                //  }
                //}
                //setCurrentProductPairs()
                // send a notification to inform that a search has started
                let userInfo: [String:Any] = [Notification.SearchStringKey:"Search set",
                                              Notification.SearchPageKey:currentSearchPage]
                NotificationCenter.default.post(name: .SearchStarted, object:nil, userInfo: userInfo)
                
                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
                    let fetchResult = OFFSearchRequest().fetchProducts(for:validQuery, on:self.currentSearchPage)
                    DispatchQueue.main.async(execute: { () -> Void in

                        switch fetchResult {
                        case .list(let searchResult):
                            // searchResult is a tuple (searchResultSize, pageNumber, pageSize, products for pageNumber)
                            self.query?.numberOfSearchResults = searchResult.0
                            // is this the first page of a search?
                            if searchResult.1 == 1 {
                                // Then we should restart with an empty product list
                                self.productPairs = []
                                self.currentSearchPage = 1
                                // if the last result in the file is a more instruction remove it
                            }
                            // Add the search results to the new product list
                            for product in searchResult.3 {
                                self.productPairs.append(ProductPair(product: product))
                            }
                            // are there more products available?
                            if searchResult.0 > self.productPairs.count + 1 {
                                self.status = .partiallyLoaded
                            } else {
                                self.status = .loaded
                            }
                            
                            //    self.setCurrentProductPairs()
                            let userInfo: [String:Any] = [Notification.SearchStringKey:"Search results loaded",
                                                          Notification.SearchOffsetKey:searchResult.1 * searchResult.2]
                            NotificationCenter.default.post(name: .SearchLoaded, object:nil, userInfo: userInfo)
                        case .loadingFailed(let barcodeString):
                            self.status = .loadingFailed(barcodeString)
                            let userInfo: [String:Any] = [:]
                            NotificationCenter.default.post(name: .SearchLoaded, object:nil, userInfo: userInfo)
                        default:
                            break
                        }
                    })
                })
            }
        }
    }
    
    
    
    func indexOfProductPair(with barcodeType: BarcodeType?) -> Int? {
        guard let validbarcodeType = barcodeType else { return nil }
        return productPairs.index(where: { $0.barcodeType.asString == validbarcodeType.asString })
    }
    
    func index(of productPair: ProductPair?) -> Int? {
        guard let validProductPair = productPair else { return nil }
        return productPairs.index(where: { $0.barcodeType.asString == validProductPair.barcodeType.asString })
    }
    
    func productPair(for barcode: BarcodeType) -> ProductPair? {
        if let index = indexOfProductPair(with: barcode){
            return productPair(at: index)
        }
        return nil
    }
    
    func productPair(at index: Int) -> ProductPair? {
        guard index >= 0 && index < productPairs.count else { return nil }
        return productPairs[index]
    }
    
    
    func flush() {
        print("Search.flush - flushing products")
        productPairs = []
        status = .notLoaded
    }
}


// Notification definitions

extension Notification.Name {
    //static let ProductListExtended = Notification.Name("OFFSearchProducts.Notification.ProductListExtended")
    //static let ProductNotAvailable = Notification.Name("OFFSearchProducts.Notification.ProductNotAvailable")
    static let SearchStarted = Notification.Name("OFFSearchProducts.Notification.SearchStarted")
    static let SearchLoaded = Notification.Name("OFFSearchProducts.Notification.SearchLoaded")
    //static let FirstProductLoaded = Notification.Name("OFFSearchProducts.Notification.FirstProductLoaded")
    //static let HistoryIsLoaded = Notification.Name("OFFSearchProducts.Notification.HistoryIsLoaded")
    //static let ProductLoadingError = Notification.Name("OFFSearchProducts.Notification.ProductLoadingError")
}


