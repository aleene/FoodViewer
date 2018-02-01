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
    
    var description: String {
        switch self {
        case .perServing:
            return TranslatableStrings.NutritionFactsPerServing
        case .perStandard:
            return TranslatableStrings.NutritionFactsPer100mgml
        case .perDailyValue:
            return TranslatableStrings.DailyValuesPerServing
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
    
    var index: Int {
        switch self {
        case .perServing: return 0
        case .perStandard: return 1
        case .perDailyValue: return 2
        }
    }
    
    var key: String {
        switch self {
        case .perServing: return "per serving"
        case .perStandard: return "per standard unit"
        case .perDailyValue: return "per daily value"
        }
    }
}
