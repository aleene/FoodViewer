//
//  NatriumChloride.swift
//  FoodViewer
//
//  Created by arnaud on 07/04/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

enum NatriumChloride {
    case Salt
    case Sodium
    
    func description() -> String {
        let preferredLanguage = NSLocale.preferredLanguages()[0]
        switch self {
        case .Salt:
            return OFFplists.manager.translateNutrients(key(), language:preferredLanguage)
        case .Sodium:
            return OFFplists.manager.translateNutrients(key(), language:preferredLanguage)
        }
    }
    
    func index() -> Int {
        switch self {
        case .Salt: return 0
        case .Sodium: return 1
        }
    }
    
    func key() -> String {
        switch self {
        case .Salt: return "salt"
        case .Sodium: return "sodium"
        }
    }
}
