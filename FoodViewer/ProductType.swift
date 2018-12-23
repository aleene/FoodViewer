//
//  ProductType.swift
//  FoodViewer
//
//  Created by arnaud on 15/04/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

enum ProductType: String {
    // warning the values must be the same as in OFF.Server
    case food = "openfoodfacts"
    case petFood = "openpetfoodfacts"
    case beauty = "openbeautyfacts"
    case product = "openproductfacts"
    
    init(string: String) {
        switch string {
        case "openfoodfacts":
            self = .food
        case "openpetfoodfacts":
            self = .petFood
        case "openbeautyfacts":
            self = .beauty
        case "openproductfacts":
            self = .product
        default:
            self = .food
        }
    }
    static func onServer(_ str: String) -> String? {
        if str == ProductType.food.rawValue {
            return ProductType.food.description()
        } else if str == ProductType.petFood.rawValue {
            return ProductType.petFood.description()
        } else if str == ProductType.beauty.rawValue {
            return ProductType.beauty.description()
        } else if str == ProductType.product.rawValue {
            return ProductType.product.description()
        }
        return nil
    }
    
    static func contains(_ server: String) -> ProductType? {
        if server == ProductType.food.rawValue {
            return .food
        } else if server == ProductType.petFood.rawValue {
            return .petFood
        } else if server == ProductType.beauty.rawValue {
            return .beauty
        } else if server == ProductType.product.rawValue {
            return .product
        }
        return nil
    }
    
    func description() -> String {
        switch self {
        case .food:
            return "Food product"
        case .petFood:
            return "Petfood product"
        case .beauty:
            return "Beauty product"
        case .product:
            return "General product"
        }
    }
}
