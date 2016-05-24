//
//  NutritionDisplayMode.swift
//  FoodViewer
//
//  Created by arnaud on 13/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

enum NutritionDisplayMode {
    case PerServing
    case PerStandard
    case PerDailyValue
    
    func description() -> String {
        switch self {
        case .PerServing:
            return NSLocalizedString("Nutrition Facts (per serving)", comment: "Description for NutritionData per serving")
        case .PerStandard:
            return NSLocalizedString("Nutrition Facts (per 100g/100ml)", comment: "Description for NutritionData per standard unit")
        case .PerDailyValue:
            return NSLocalizedString("Daily Values (per serving)", comment: "Description for NutritionData Daily Value per serving")
        }
    }
    
    func index() -> Int {
        switch self {
        case .PerServing: return 0
        case .PerStandard: return 1
        case .PerDailyValue: return 2
        }
    }
    
    func key() -> String {
        switch self {
        case .PerServing: return "per serving"
        case .PerStandard: return "per standard unit"
        case .PerDailyValue: return "daily value"
        }
    }
}
