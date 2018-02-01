//
//  NutritionEntryUnit.swift
//  FoodViewer
//
//  Created by arnaud on 14/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//


import Foundation

// this enum describes how the user entered the nutrition data

public enum NutritionEntryUnit {
    
    case perServing
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
