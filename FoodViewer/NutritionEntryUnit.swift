//
//  NutritionEntryUnit.swift
//  FoodViewer
//
//  Created by arnaud on 14/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//


import Foundation

// this enum describes how the user entered the nutrition data

enum NutritionEntryUnit {
    
    case PerServing
    case PerStandardUnit
    
    func description() -> String {
        switch self {
        case .PerServing: return NSLocalizedString("nutrition data indicated per serving", comment: "description() text if the nutrition data on the package is indicated per serving.")
        case .PerStandardUnit: return NSLocalizedString("no nutrition data indicated per standard unit", comment: "description() text if the nutrition data on the package is indicated per standard unit (100 g or 100 ml).")
            
        }
    }
    
    func key() -> String {
        switch self {
        case .PerServing: return "serving"
        case .PerStandardUnit: return "100g"
        }
    }
}
