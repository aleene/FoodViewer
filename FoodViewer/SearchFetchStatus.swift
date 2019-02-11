//
//  SearchFetchStatus.swift
//  FoodViewer
//
//  Created by arnaud on 04/02/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import Foundation

enum SearchFetchStatus {
    case uninitialized
    // a search as been defined, but without any definition
    case initialized
    //
    case notDefined
    // the search query is available, but the products are not yet loaded
    case notLoaded
    // the products are being loaded
    case loading
    // The searchList returns a facet of the search result,
    // as a tuple (searchResultSize, pageNumber, pageSize, products for pageNumber)
    case list((Int, Int, Int, [FoodProduct]))
    case partiallyLoaded
    case loaded
    case noResults
    case loadingFailed(String)
    
    var description: String {
        switch self {
        case .uninitialized: return TranslatableStrings.Unknown
        case .initialized: return TranslatableStrings.Initialized
        case .notDefined: return TranslatableStrings.NotSet
        case .notLoaded: return TranslatableStrings.ProductNotLoaded
        case .loading: return TranslatableStrings.SearchLoading
        case .partiallyLoaded: return TranslatableStrings.LoadMoreResults
        case .loaded: return TranslatableStrings.DataIsLoaded
        case .list: return TranslatableStrings.ProductListIsLoaded
        case .noResults: return TranslatableStrings.NoSearchResult
        case .loadingFailed: return TranslatableStrings.ProductLoadingFailed
        }
    }

    var rawValue: Int {
        switch self {
        case .uninitialized: return 0
        case .initialized: return 1
        case .notDefined: return 2
            
        case .notLoaded: return 3
        case .loading: return 4
        case .partiallyLoaded: return 5
        case .loaded: return 6
        case .list: return 7
        case .noResults: return 8
        case .loadingFailed: return 9
        }
    }
    
    static func description(for rawValue: Int) -> String {
        switch rawValue {
        case SearchFetchStatus.uninitialized.rawValue:
            return SearchFetchStatus.uninitialized.description
        case SearchFetchStatus.initialized.rawValue:
            return SearchFetchStatus.initialized.description
        case SearchFetchStatus.notDefined.rawValue:
            return SearchFetchStatus.notDefined.description
        case SearchFetchStatus.notLoaded.rawValue:
            return SearchFetchStatus.notLoaded.description
        case SearchFetchStatus.loading.rawValue:
            return SearchFetchStatus.loading.description
        case SearchFetchStatus.partiallyLoaded.rawValue:
            return SearchFetchStatus.partiallyLoaded.description
        case SearchFetchStatus.loaded.rawValue:
            return SearchFetchStatus.loaded.description
        case SearchFetchStatus.list((Int(), Int(), Int(), [FoodProduct()])).rawValue:
            return SearchFetchStatus.list((Int(), Int(), Int(), [FoodProduct()])).description
        case SearchFetchStatus.noResults.rawValue:
            return SearchFetchStatus.noResults.description
        default:
            return SearchFetchStatus.loadingFailed(String()).description
        }
    }
}
