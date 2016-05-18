//
//  NutritionDataPerStandardOrServing.swift
//  FoodViewer
//
//  Created by arnaud on 13/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

enum NutritionDataPerStandardOrServing {
    case PerServing
    case PerStandard
    
    func description() -> String {
        switch self {
        case .PerServing:
            return NSLocalizedString("Nutrition Facts (per serving)", comment: "Description for NutritionData per serving")
        case .PerStandard:
            return NSLocalizedString("Nutrition Facts (per 100g/100ml)", comment: "Description for NutritionData per standard unit")
        }
    }
    
    func index() -> Int {
        switch self {
        case .PerServing: return 0
        case .PerStandard: return 1
        }
    }
    
    func key() -> String {
        switch self {
        case .PerServing: return "per serving"
        case .PerStandard: return "sodium"
        }
    }
}
