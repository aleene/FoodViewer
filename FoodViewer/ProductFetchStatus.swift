//
//  ProductFetchStatus.swift
//  FoodViewer
//
//  Created by arnaud on 11/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

enum ProductFetchStatus {
    // The productFetchStatus describes the prossible status changes of the remoteProduct
    // nothing is known at the moment
    case initialized
    // the barcode is set, but no load is initialised
    case productNotLoaded(String) // (barcodeString)
    // loading indicates that it is trying to load the product
    case loading(String) // The string indicates the barcodeString
    // the product has been loaded successfully and can be set.
    case success(FoodProduct)
    // available implies that the product has been retrieved and is available for usage
    case available(String)
    // when the user has successfully uploaded a new version
    case updated(String)
    // the product is not available on the off servers
    case productNotAvailable(String) // (barcodeString)
    // the loading did not succeed
    case loadingFailed(String) // (barcodeString)

    var description: String {
        switch self {
        case .initialized: return TranslatableStrings.Initialized
        case .productNotLoaded: return TranslatableStrings.ProductNotLoaded
        case .loading: return TranslatableStrings.ProductLoading
        case .success: return TranslatableStrings.ProductIsLoaded
        case .available: return TranslatableStrings.ProductIsLoaded
        case .updated: return TranslatableStrings.ProductIsUpdated
        case .loadingFailed: return TranslatableStrings.ProductLoadingFailed
        case .productNotAvailable: return TranslatableStrings.ProductNotAvailable
        }
    }
    
    var rawValue: Int {
        switch self {
        case .initialized: return 0
        case .productNotLoaded: return 1
        case .loading: return 2
        case .success: return 3
        case .available: return 4
        case .updated: return 5
        case .productNotAvailable: return 6
        case .loadingFailed: return 7
        }
    }
    
    static func description(for value: Int) -> String {
        switch value {
        case ProductFetchStatus.initialized.rawValue:
            return ProductFetchStatus.initialized.description
        case ProductFetchStatus.productNotLoaded(String()).rawValue :
            return  ProductFetchStatus.productNotLoaded(String()).description
        case ProductFetchStatus.success(FoodProduct()).rawValue :
            return ProductFetchStatus.success(FoodProduct()).description
        case ProductFetchStatus.available(String()).rawValue :
            return ProductFetchStatus.available(String()).description
        case ProductFetchStatus.loading(String()).rawValue :
            return ProductFetchStatus.loading(String()).description
        case ProductFetchStatus.loadingFailed(String()).rawValue :
            return ProductFetchStatus.loadingFailed(String()).description
        case ProductFetchStatus.productNotAvailable(String()).rawValue :
            return ProductFetchStatus.productNotAvailable(String()).description
        default:
            return "ProductFetchStatus: unknown rawValue"
        }
    }
}
