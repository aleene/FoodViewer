//
//  NutritionDisplayMode.swift
//  FoodViewer
//
//  Created by arnaud on 13/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

enum NutritionDisplayMode {
    case perServing
    case perStandard
    case perDailyValue
    
    func description() -> String {
        switch self {
        case .perServing:
            return NSLocalizedString("Nutrition Facts (per serving)", comment: "Description for NutritionData per serving")
        case .perStandard:
            return NSLocalizedString("Nutrition Facts (per 100g/100ml)", comment: "Description for NutritionData per standard unit")
        case .perDailyValue:
            return NSLocalizedString("Daily Values (per serving)", comment: "Description for NutritionData Daily Value per serving")
        }
    }
    
    init(_ index: Int) {
        switch index {
        case 1:
            self = .perServing
        case 2:
            self = .perServing
        default:
            self = .perStandard
        }
    }
    
    func index() -> Int {
        switch self {
        case .perServing: return 0
        case .perStandard: return 1
        case .perDailyValue: return 2
        }
    }
    
    func key() -> String {
        switch self {
        case .perServing: return "per serving"
        case .perStandard: return "per standard unit"
        case .perDailyValue: return "per daily value"
        }
    }
}
