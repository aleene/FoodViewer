//
//  ProductType.swift
//  FoodViewer
//
//  Created by arnaud on 15/04/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

enum ProductType: String {
    case food = "off"
    case petFood = "opff"
    case beauty = "obf"
    
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
