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
    
    case perServing
    case perStandardUnit
    
    func description() -> String {
        switch self {
        case .perServing: return NSLocalizedString("nutrition data indicated per serving", comment: "description() text if the nutrition data on the package is indicated per serving.")
        case .perStandardUnit: return NSLocalizedString("no nutrition data indicated per standard unit", comment: "description() text if the nutrition data on the package is indicated per standard unit (100 g or 100 ml).")
            
        }
    }
    
    func key() -> String {
        switch self {
        case .perServing: return "serving"
        case .perStandardUnit: return "100g"
        }
    }
}
