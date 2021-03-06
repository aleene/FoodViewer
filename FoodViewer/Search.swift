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
    
    var query: SearchTemplate? = nil
    
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
    
    var status: SearchFetchStatus {
        if query == nil {
            return .uninitialized
        } else {
            if componentsCount > 0 {
                return loadStatus
                //if productPairs.count > 0 {
                //    return loadStatus
                //} else {
                //    return .notLoaded
                //}
            } else {
                return .initialized
            }
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
    
    func startSearch() {
        if query != nil {
            loadAll()
        }
    }
    
    var searchResultSize: Int? = nil

    init() {
        self.query = SearchTemplate()
    }
    
    // initialize with a defined template
    convenience init(query:SearchTemplate) {
        self.init()
        self.query = query
    }
    
    convenience init(for string: String?, in category: SearchComponent) {
        self.init()
        guard string != nil else { return }
        let validString = string!.contains(":") ?
            string!.split(separator:":").map(String.init)[1] : string!
        createSearchQuery(for:(category, validString))
    }

    
    private var loadStatus: SearchFetchStatus = .notLoaded

    private func createSearchQuery(for tuple:(SearchComponent?, String?)?) {
        if let validSearch = tuple,
            let validComponent = validSearch.0,
            let validString = validSearch.1 {
            query = SearchTemplate(for:validString, in:validComponent)
        } else {
            query = nil
        }
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
                loadStatus = .loading
                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
                    let fetchResult = OFFSearchRequest().fetchProducts(for:validQuery, on:self.currentSearchPage)
                    DispatchQueue.main.async(execute: { () -> Void in

                        switch fetchResult {
                        case .list(let searchResult):
                            // searchResult is a tuple (searchResultSize, pageNumber, pageSize, products for pageNumber)
                            self.searchResultSize = searchResult.0
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
                                self.loadStatus = .partiallyLoaded
                            } else {
                                self.loadStatus = .loaded
                            }
                            
                            //    self.setCurrentProductPairs()
                            let userInfo: [String:Any] = [Notification.SearchStringKey:"Search results loaded",
                                                          Notification.SearchOffsetKey:searchResult.1 * searchResult.2]
                            NotificationCenter.default.post(name: .SearchLoaded, object:nil, userInfo: userInfo)
                        case .loadingFailed(let barcodeString):
                            self.loadStatus = .loadingFailed(barcodeString)
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
        return productPairs.firstIndex(where: { $0.barcodeType.asString == validbarcodeType.asString })
    }
    
    func index(of productPair: ProductPair?) -> Int? {
        guard let validProductPair = productPair else { return nil }
        return productPairs.firstIndex(where: { $0.barcodeType.asString == validProductPair.barcodeType.asString })
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
        loadStatus = .notLoaded
    }
}


// Notification definitions

extension Notification.Name {
    static let SearchStarted = Notification.Name("OFFSearchProducts.Notification.SearchStarted")
    static let SearchLoaded = Notification.Name("OFFSearchProducts.Notification.SearchLoaded")
}


