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
    /// Nutritional values for nutrients are entered per 100g or 100ml
    case perStandardUnit
    
    func description() -> String {
        switch self {
        case .perServing:
            return TranslatableStrings.PerServing
        case .perStandardUnit:
            return TranslatableStrings.Per100mgml
        }
    }
    
    public var key: String {
        switch self {
        case .perServing:
            return "serving"
        case .perStandardUnit:
            return "100g"
        }
    }
    
    public init() {
        self = .perStandardUnit
    }
}
