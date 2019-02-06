//
//  SearchFetchStatus.swift
//  FoodViewer
//
//  Created by arnaud on 04/02/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import Foundation

enum SearchFetchStatus {
    // nothing is known at the moment
    case initialized
    
    // TOD:
    // The searchList returns a facet of the search result,
    // as a tuple (searchResultSize, pageNumber, pageSize, products for pageNumber)
    case noSearchDefined
    case searchLoading
    case searchQuery(SearchTemplate)
    case searchList((Int, Int, Int, [FoodProduct]))
    case searchLoadingFailed(String)
    // The more parameter defines the search next page to retrieve
    case more(Int)
    
    var description: String {
        switch self {
        case .initialized: return TranslatableStrings.Initialized
        case .noSearchDefined: return TranslatableStrings.NoSearchDefined
        case .searchLoading: return TranslatableStrings.SearchLoading
        case .searchQuery: return TranslatableStrings.SearchQuery
        case .searchList: return TranslatableStrings.ProductListIsLoaded
        case .searchLoadingFailed: return TranslatableStrings.ProductLoadingFailed
        case .more: return TranslatableStrings.LoadMoreResults
        }
    }
    
    var rawValue: Int {
        switch self {
        case .initialized: return 0
        case .searchLoadingFailed: return 7
        case .noSearchDefined: return 10
        case .searchLoading: return 11
        case .searchQuery: return 14
        case .searchList: return 13
        case .more: return 12
        }
    }
    
}
