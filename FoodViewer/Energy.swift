//
//  Energy.swift
//  FoodViewer
//
//  Created by arnaud on 20/04/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

enum Energy {
    case calories
    case joule
    
    func description() -> String {
        let preferredLanguage = Locale.preferredLanguages[0]
        switch self {
        case .calories:
            return OFFplists.manager.translateNutrients(Energy.key, language:preferredLanguage)
        case .joule:
            return OFFplists.manager.translateNutrients(Energy.key, language:preferredLanguage)
        }
    }
    
    func unit() -> String {
        switch self {
        case .calories: return "kcal"
        case .joule: return "kJ"
        }

    }
    
    func index() -> Int {
        switch self {
        case .calories: return 1
        case .joule: return 0
        }
    }
    
    static let key = "energy"

    static let prefixKey = "en:energy"

}
