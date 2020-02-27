//
//  NutritionFactsTableStyleSetter.swift
//  FoodViewer
//
//  Created by arnaud on 23/05/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation

enum NutritionFactsTableStyleSetter {
    case user
    case product
    
    init() {
        self = .product
    }
    
    var definition: String {
        switch self {
        case .user:
            return "Nutrition Facts Table style is set by the user."
        case .product:
            return "Nutrition Facts Table style is set by the product."
        }
    }

}
