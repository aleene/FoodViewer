//
//  NutritionEntryUnit.swift
//  FoodViewer
//
//  Created by arnaud on 14/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//


import Foundation

/// This enum describes how the user entered the nutrition data
public enum NutritionEntryUnit {
    
    /// Nutritional values for nutrients are entered per serving
    case perServing
    /// Nutritional values for nutrients are entered per daily Value percentage
    case perDailyValue
    /// Nutritional values for nutrients are entered per 100g or 100ml
    case perStandardUnit
    /// Nutritional values for nutrients are entered per kg or L
    case per1000Gram

    public var description: String {
        switch self {
        case .perServing:
            return TranslatableStrings.PerServing
        case .perStandardUnit:
            return TranslatableStrings.Per100mgml
        case .per1000Gram:
            return TranslatableStrings.PerKilogram
        case .perDailyValue:
            return TranslatableStrings.PerDailyValue
        }
    }
    
    /// A string key used in the OFF json encoding
    public var key: String {
        switch self {
        case .perServing:
            return "serving"
        case .perStandardUnit:
            return "100g"
        default: return ""
        }
    }

    
    public init() {
        self = .perStandardUnit
    }
}
