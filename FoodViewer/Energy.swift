//
//  Energy.swift
//  FoodViewer
//
//  Created by arnaud on 20/04/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

enum Energy {
    case Calories
    case Joule
    
    func description() -> String {
        let preferredLanguage = NSLocale.preferredLanguages()[0]
        switch self {
        case .Calories:
            return OFFplists.manager.translateNutrients(key(), language:preferredLanguage)
        case .Joule:
            return OFFplists.manager.translateNutrients(key(), language:preferredLanguage)
        }
    }
    
    func unit() -> String {
        switch self {
        case .Calories: return "kcal"
        case .Joule: return "kJ"
        }

    }
    
    func index() -> Int {
        switch self {
        case .Calories: return 1
        case .Joule: return 0
        }
    }
    
    func key() -> String {
        return "energy"
    }
}
