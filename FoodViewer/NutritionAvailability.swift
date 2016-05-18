//
//  NutritionAvailability.swift
//  FoodViewer
//
//  Created by arnaud on 12/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

enum NutritionAvailability {
    
    case PerServing
    case PerStandardUnit
    case PerServingAndStandardUnit
    case NotOnPackage
    case NotIndicated
    case NotAvailable
    
    func description() -> String {
        switch self {
        case .PerServing: return NSLocalizedString("nutrition data per serving available", comment: "Text in a TagListView, when the nutrition data has been specified in the product data.")
        case .PerStandardUnit: return NSLocalizedString("nutrition data per standard unit available", comment: "Text in a TagListView, when the nutrition data has been specified in the product data.")
        case .PerServingAndStandardUnit: return NSLocalizedString("nutrition data per serving and standard unit available", comment: "Text in a TagListView, when the nutrition data has been specified in the product data.")
        case .NotOnPackage: return NSLocalizedString("nutrition data not on package", comment: "Text in a TagListView, when no nutrition data is available on the package.")
        case .NotIndicated: return NSLocalizedString("no nutrition data indicated", comment: "Text in a TagListView, when no nutrition data has been specified in the product data.")
        case .NotAvailable: return NSLocalizedString("no nutrition data available", comment: "Text in a TagListView, when no nutrition data has been specified in the product data.")
        }
    }
}
