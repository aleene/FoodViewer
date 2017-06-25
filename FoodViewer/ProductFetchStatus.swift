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
    case list([FoodProduct])
    case loading
    case productNotAvailable(String)
    case loadingFailed(String)
    case initialized
    case other(String)

    func description() -> String {
        switch self {
        case .success: return NSLocalizedString("Product is loaded", comment: "String presented in a tagView if the product has been loaded")
        case .list: return NSLocalizedString("Product list is loaded", comment: "String presented in a tagView if the product list has been loaded")
        case .loading: return NSLocalizedString("Product loading", comment: "String presented in a tagView if the product is currently being loaded")
        case .loadingFailed: return NSLocalizedString("Product loading  failed", comment: "String presented in a tagView if the product loading has failed")
        case .initialized: return NSLocalizedString("Initialized", comment: "String presented in a tagView if nothing has happened yet")
        case .productNotAvailable: return NSLocalizedString("Product not available", comment: "String presented in a tagView if no product is available on OFF")
        case .other: return NSLocalizedString("Other product type", comment: "String presented in a tagView if this is not the current product type")

        }
    }
}
