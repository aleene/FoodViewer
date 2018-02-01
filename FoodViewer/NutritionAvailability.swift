//
//  NutritionAvailability.swift
//  FoodViewer
//
//  Created by arnaud on 12/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

enum NutritionAvailability {
    
    case perServing
    case perStandardUnit
    case perServingAndStandardUnit
    case notOnPackage
    case notIndicated
    case notAvailable
    
    func description() -> String {
        switch self {
        case .perServing: return TranslatableStrings.PerServing
        case .perStandardUnit: return TranslatableStrings.Per100mgml
        case .perServingAndStandardUnit: return  TranslatableStrings.PerServingAndStandardUnit
        case .notOnPackage: return TranslatableStrings.NotOnPackage
        case .notIndicated: return TranslatableStrings.NoNutritionDataIndicated
        case .notAvailable: return TranslatableStrings.NoNutritionDataAvailable
        }
    }
}
