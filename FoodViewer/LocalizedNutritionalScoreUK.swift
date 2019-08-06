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

        pointsA[0].nutriment = OFFplists.manager.translateNutrient(Constants.energyKey, language:preferredLanguage) ?? Constants.energyKey
        pointsA[1].nutriment = OFFplists.manager.translateNutrient(UKConstants.saturatedFatKey, language:preferredLanguage) ?? UKConstants.saturatedFatKey
        pointsA[2].nutriment = OFFplists.manager.translateNutrient(Constants.sugarsKey, language:preferredLanguage) ?? Constants.sugarsKey
        pointsA[3].nutriment = OFFplists.manager.translateNutrient(Constants.sodiumKey, language:preferredLanguage) ?? Constants.sodiumKey
        
        pointsC[0].nutriment = OFFplists.manager.translateNutrient(Constants.fruitsVegetablesNutsKey, language:preferredLanguage) ?? Constants.fruitsVegetablesNutsKey
        pointsC[1].nutriment = OFFplists.manager.translateNutrient(Constants.fiberKey, language:preferredLanguage) ?? Constants.fiberKey
        pointsC[2].nutriment = OFFplists.manager.translateNutrient(Constants.fiberKey, language:preferredLanguage) ?? Constants.fiberKey
    }
}
