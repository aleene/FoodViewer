//
//  NutritionDisplayMode.swift
//  FoodViewer
//
//  Created by arnaud on 13/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

enum NutritionDisplayMode: Int {
    case perStandard = 0
    case perThousandGram = 1
    case perServing = 2
    case perDailyValue = 3
    
    var description: String {
        switch self {
        case .perServing:
            return TranslatableStrings.NutritionFactsPerServing
        case .perStandard:
            return TranslatableStrings.NutritionFactsPer100gml
        case .perThousandGram:
            return TranslatableStrings.NutritionFactsPer1000Gram
        case .perDailyValue:
            return TranslatableStrings.DailyValuesPerServing
        }
    }
    
    init(_ index: Int) {
        switch index {
        case NutritionDisplayMode.perServing.rawValue:
            self = .perServing
        case NutritionDisplayMode.perThousandGram.rawValue:
            self = .perThousandGram
        case NutritionDisplayMode.perDailyValue.rawValue:
            self = .perDailyValue
        default:
            self = .perStandard
        }
    }
    /*
    public var index: Int {
        switch self {
        case .perServing: return NutritionDisplayMode.perServing.rawValue
        case .perStandard: return NutritionDisplayMode.perStandard.rawValue
        case .perThousandGram: return NutritionDisplayMode.perThousandGram.rawValue
        case .perDailyValue: return NutritionDisplayMode.perDailyValue.rawValue
        }
    }
 */
    
    public var key: String {
        switch self {
        case .perServing: return "per serving"
        case .perStandard: return "per standard unit"
        case .perThousandGram: return "per 1000 gram"
        case .perDailyValue: return "per daily value"
        }
    }
    
    public var nutritionEntryUnit: NutritionEntryUnit {
        switch self {
        case .perServing: return .perServing
        case .perStandard: return .perStandardUnit
        case .perThousandGram: return .perStandardUnit
        case .perDailyValue: return .perStandardUnit
        }
    }
}
