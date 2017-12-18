//
//  Energy.swift
//  FoodViewer
//
//  Created by arnaud on 20/04/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

enum EnergyUnitUsed {
    case calories
    case kilocalorie
    case joule
    
    func description() -> String {
        let preferredLanguage = Locale.preferredLanguages[0]
        switch self {
        case .calories:
            return OFFplists.manager.translateNutrients(LocalizedEnergy.key, language:preferredLanguage)
        case .kilocalorie:
            return OFFplists.manager.translateNutrients(LocalizedEnergy.key, language:preferredLanguage)
        case .joule:
            return OFFplists.manager.translateNutrients(LocalizedEnergy.key, language:preferredLanguage)
        }
    }
    
    func unit() -> String {
        let energy = Energy()
        energy.quantity = 1.0
        switch self {
        case .calories:
            let (_, unit) = energy.inLargeCalories
            return unit
        case .kilocalorie:
            let (_, unit) = energy.inKiloCalories
            return unit
        case .joule:
            let (_, unit) = energy.inKilo
            return unit
        }

    }
    
}
