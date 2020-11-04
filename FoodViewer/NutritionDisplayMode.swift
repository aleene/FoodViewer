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
    case perThousandGram
    case perDailyValue
    
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
        case 1:
            self = .perServing
        case 2:
            self = .perThousandGram
        case 3:
            self = .perServing
        default:
            self = .perStandard
        }
    }
    
    public var index: Int {
        switch self {
        case .perServing: return 0
        case .perStandard: return 1
        case .perThousandGram: return 2
        case .perDailyValue: return 3
        }
    }
    
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
