//
//  LocalizedNutritionalScoreUK.swift
//  FoodViewer
//
//  Created by arnaud on 09/06/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

class LocalizedNutritionalScoreUK: NutritionalScoreUK {
    
    override init() {
        super.init()
        setup()
    }
    
    fileprivate func setup() {
        let preferredLanguage = Locale.preferredLanguages[0]

        pointsA[0].nutriment = OFFplists.manager.translateNutrients(Constants.energyKey, language:preferredLanguage)
        pointsA[1].nutriment = OFFplists.manager.translateNutrients(UKConstants.saturatedFatKey, language:preferredLanguage)
        pointsA[2].nutriment = OFFplists.manager.translateNutrients(Constants.sugarsKey, language:preferredLanguage)
        pointsA[3].nutriment = OFFplists.manager.translateNutrients(Constants.sodiumKey, language:preferredLanguage)
        
        pointsC[0].nutriment = OFFplists.manager.translateNutrients(Constants.fruitsVegetablesNutsKey, language:preferredLanguage)
        pointsC[1].nutriment = OFFplists.manager.translateNutrients(Constants.fiberKey, language:preferredLanguage)
        pointsC[2].nutriment = OFFplists.manager.translateNutrients(Constants.proteinsKey, language:preferredLanguage)
    }
}
