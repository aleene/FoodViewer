//
//  LocalizedNutritionalScoreFR.swift
//  FoodViewer
//
//  Created by arnaud on 10/03/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

class LocalizedNutritionalScoreFR: NutritionalScoreFR {
    
    public override init() {
        super.init()
        setup()
    }
    
    private func setup() {
        let preferredLanguage = Locale.preferredLanguages[0]
        
        pointsA[0].nutriment = OFFplists.manager.translateNutrients(Constants.energyKey, language:preferredLanguage)
        pointsA[1].nutriment = TranslatableStrings.SaturatedFatToFatRatio
        pointsA[2].nutriment = OFFplists.manager.translateNutrients(Constants.sugarsKey, language:preferredLanguage)
        pointsA[3].nutriment = OFFplists.manager.translateNutrients(Constants.sodiumKey, language:preferredLanguage)
        
        pointsC[0].nutriment = OFFplists.manager.translateNutrients(Constants.fruitsVegetablesNutsKey, language:preferredLanguage)
        pointsC[1].nutriment = OFFplists.manager.translateNutrients(Constants.fiberKey, language:preferredLanguage)
        pointsC[2].nutriment = OFFplists.manager.translateNutrients(Constants.proteinsKey, language:preferredLanguage)
    }
}

