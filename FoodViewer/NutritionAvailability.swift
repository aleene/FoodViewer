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
        case .perServing: return NSLocalizedString("nutrition data per serving available", comment: "Text in a TagListView, when the nutrition data has been specified in the product data.")
        case .perStandardUnit: return NSLocalizedString("nutrition data per standard unit available", comment: "Text in a TagListView, when the nutrition data has been specified in the product data.")
        case .perServingAndStandardUnit: return NSLocalizedString("nutrition data per serving and standard unit available", comment: "Text in a TagListView, when the nutrition data has been specified in the product data.")
        case .notOnPackage: return NSLocalizedString("nutrition data not on package", comment: "Text in a TagListView, when no nutrition data is available on the package.")
        case .notIndicated: return NSLocalizedString("no nutrition data indicated", comment: "Text in a TagListView, when no nutrition data has been specified in the product data.")
        case .notAvailable: return NSLocalizedString("no nutrition data available", comment: "Text in a TagListView, when no nutrition data has been specified in the product data.")
        }
    }
}
