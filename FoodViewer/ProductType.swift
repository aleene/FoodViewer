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
    
    func description() -> String {
        switch self {
        case .food:
            return "Food product"
        case .petFood:
            return "Petfood product"
        case .beauty:
            return "Beauty product"
        }
    }
}
