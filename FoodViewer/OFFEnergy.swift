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
        return OFFplists.manager.translateNutrient(LocalizedEnergy.key, language:preferredLanguage) ?? LocalizedEnergy.key
    }
    
}

class LocalizedEnergyKcal : Energy {
    
    enum UnitsToUse {
        case calories
        case joule
    }
    
    static let key = "energy-kcal"
    static let prefixKey = "en:energy-kcal"
    
    public var baseUnit: UnitsToUse = .calories

    public var title: String {
        let preferredLanguage = Locale.preferredLanguages[0]
        return OFFplists.manager.translateNutrient(LocalizedEnergyKcal.key, language:preferredLanguage) ?? LocalizedEnergyKcal.key
    }
    
}

