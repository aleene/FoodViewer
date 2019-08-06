//
//  NatriumChloride.swift
//  FoodViewer
//
//  Created by arnaud on 07/04/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

enum NatriumChloride {
    case salt
    case sodium
    
    func description() -> String {
        let preferredLanguage = Locale.preferredLanguages[0]
        switch self {
        case .salt:
            return OFFplists.manager.translateNutrient(key, language:preferredLanguage) ?? key
        case .sodium:
            return OFFplists.manager.translateNutrient(key, language:preferredLanguage) ?? key
        }
    }
    
    var index: Int {
        switch self {
        case .salt: return 0
        case .sodium: return 1
        }
    }
    
    var key: String {
        switch self {
        case .salt: return "salt"
        case .sodium: return "sodium"
        }
    }
}
