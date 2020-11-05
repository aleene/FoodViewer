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
    
    static let key = Nutrient.energy.rawValue
    static let prefixKey = "en:" + key
    
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
    
    static let key = Nutrient.energyKcal.rawValue
    
    public var baseUnit: UnitsToUse = .calories

    public var title: String {
        let preferredLanguage = Locale.preferredLanguages[0]
        return OFFplists.manager.translateNutrient(LocalizedEnergyKcal.key, language:preferredLanguage) ?? LocalizedEnergyKcal.key
    }
    
}
   
class LocalizedEnergyFromFat : Energy {
        
    enum UnitsToUse {
        case calories
        case joule
    }
        
    static let key = Nutrient.energyFromFat.rawValue
    static let prefixKey = "en:" + key
        
    public var baseUnit: UnitsToUse = .calories

    public var title: String {
        let preferredLanguage = Locale.preferredLanguages[0]
        return OFFplists.manager.translateNutrient(LocalizedEnergyFromFat.key, language:preferredLanguage) ?? LocalizedEnergyFromFat.key
    }
        
}

