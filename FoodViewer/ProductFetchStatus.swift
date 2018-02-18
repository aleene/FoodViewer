//
//  ProductFetchStatus.swift
//  FoodViewer
//
//  Created by arnaud on 11/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

enum ProductFetchStatus {
    case available
    case success(FoodProduct)
    // The searchList returns a facet of the search result, 
    // as a tuple (searchResultSize, pageNumber, pageSize, products for pageNumber)
    case loading(FoodProduct) // (barcodeString)
    case productNotLoaded(FoodProduct) // (barcodeString)
    case productNotAvailable(FoodProduct, String) // (barcodeString, error string)
    case loadingFailed(FoodProduct, String) // (barcodeString, error string)
    case initialized
    
    case noSearchDefined
    case searchLoading
    case searchQuery(SearchTemplate)
    case searchList((Int, Int, Int, [FoodProduct]))
    // The more parameter defines the search next page to retrieve
    case more(Int)

    case other(String)

    var description: String {
        switch self {
        case .initialized: return TranslatableStrings.Initialized
        case .productNotLoaded: return TranslatableStrings.ProductNotLoaded
        case .loading: return TranslatableStrings.ProductLoading
        case .success: return TranslatableStrings.ProductIsLoaded
        case .available: return TranslatableStrings.ProductIsLoaded
        case .loadingFailed: return TranslatableStrings.ProductLoadingFailed
        case .productNotAvailable: return TranslatableStrings.ProductNotAvailable
            
        case .noSearchDefined: return TranslatableStrings.NoSearchDefined
        case .searchLoading: return TranslatableStrings.SearchLoading
        case .searchQuery: return TranslatableStrings.SearchQuery
        case .searchList: return TranslatableStrings.ProductListIsLoaded
        case .more: return TranslatableStrings.LoadMoreResults

        case .other: return TranslatableStrings.OtherProductType
        }
    }
    
    var rawValue: Int {
        switch self {
        case .initialized: return 0
        case .productNotLoaded: return 1
        case .loading: return 2
        case .success: return 3
        case .available: return 4
        case .productNotAvailable: return 5
        case .loadingFailed: return 6

        case .noSearchDefined: return 10
        case .searchLoading: return 11
        case .searchQuery: return 12
        case .searchList: return 13
        case .more: return 14
            
        case .other: return 20
        }
    }
}
