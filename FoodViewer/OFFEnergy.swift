//
//  OFFEnergy.swift
//  FoodViewer
//
//  Created by arnaud on 16/03/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

class LocalizedEnergy : Energy {
    
    enum UnitsToUse {
        case calories
        case joule
    }
    
    static let key = "energy"
    static let prefixKey = "en:energy"
    
    public var baseUnit: UnitsToUse = .joule

    public var title: String {
        let preferredLanguage = Locale.preferredLanguages[0]
        return OFFplists.manager.translateNutrients(LocalizedEnergy.key, language:preferredLanguage)
    }
    
}
