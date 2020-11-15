//
//  NutritionAvailability.swift
//  FoodViewer
//
//  Created by arnaud on 12/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

/**
 Indicates what  nutrition data are available:
    - perServing: only per serving data
    - per standardUnit: only per 100g/100 ml
    - per ServingAndStandardUnit: data is available per serving AND per 100g
    - notOnpackage: there is no nutrition data on the package indicated
    - notIndicated: there should be nutrition data, but has not been filled in yet
    - notAvailable: no relevant info from OFF received
 */
enum NutritionAvailability {
    
    case perServing
    case perStandardUnit
    case perServingAndStandardUnit
    case notOnPackage
    case notIndicated
    case notAvailable
    
    var description: String {
        switch self {
        case .perServing:
            return TranslatableStrings.PerServing
        case .perStandardUnit:
            return TranslatableStrings.Per100mgml
        case .perServingAndStandardUnit:
            return  TranslatableStrings.PerServingAndStandardUnit
        case .notOnPackage:
            return TranslatableStrings.NotOnPackage
        case .notIndicated:
            return TranslatableStrings.NoNutritionDataIndicated
        case .notAvailable:
            return TranslatableStrings.NoNutritionDataAvailable
        }
    }
}
