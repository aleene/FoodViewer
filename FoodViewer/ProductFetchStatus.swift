//
//  ProductFetchStatus.swift
//  FoodViewer
//
//  Created by arnaud on 11/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

enum ProductFetchStatus {
    
    case success(FoodProduct)
    // The searchList returns a facet of the search result, 
    // as a tuple (searchResultSize, pageNumber, pageSize, products for pageNumber)
    case searchList((Int, Int, Int, [FoodProduct]))
    case searchQuery(SearchTemplate)
    case loading(FoodProduct)
    case productNotLoaded(FoodProduct)
    case searchLoading
    // The more parameter defines the search next page to retrieve
    case more(Int)
    case productNotAvailable(String)
    case loadingFailed(String)
    case initialized
    case other(String)

    var description: String {
        switch self {
        case .success: return TranslatableStrings.ProductIsLoaded
        case .searchQuery: return TranslatableStrings.SearchQuery
        case .searchList: return TranslatableStrings.ProductListIsLoaded
        case .loading: return TranslatableStrings.ProductLoading
        case .productNotLoaded: return TranslatableStrings.ProductNotLoaded
        case .searchLoading: return TranslatableStrings.SearchLoading
        case .more: return TranslatableStrings.LoadMoreResults
        case .loadingFailed: return TranslatableStrings.ProductLoadingFailed
        case .initialized: return TranslatableStrings.Initialized
        case .productNotAvailable: return TranslatableStrings.ProductNotAvailable
        case .other: return TranslatableStrings.OtherProductType

        }
    }
}
