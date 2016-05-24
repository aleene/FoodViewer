//
//  ProductFetchStatus.swift
//  FoodViewer
//
//  Created by arnaud on 11/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

enum ProductFetchStatus {
    
    case Success(FoodProduct)
    case Loading
    case ProductNotAvailable(String)
    case LoadingFailed(String)
    case Initialized

    func description() -> String {
        switch self {
        case .Success: return NSLocalizedString("Product is loaded", comment: "String presented in a tagView if the product has been loaded")
        case .Loading: return NSLocalizedString("Product loading", comment: "String presented in a tagView if the product is currently being loaded")
        case .LoadingFailed: return NSLocalizedString("Product loading  failed", comment: "String presented in a tagView if the product loading has failed")
        case .Initialized: return NSLocalizedString("Initialized", comment: "String presented in a tagView if nothing has happened yet")
        case .ProductNotAvailable: return NSLocalizedString("Product not available", comment: "String presented in a tagView if no product is available on OFF")

        }
    }
}