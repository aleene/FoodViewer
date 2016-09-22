//
//  NutritionalScoreUK.swift
//  FoodViewer
//
//  Created by arnaud on 09/06/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

struct NutritionalScoreUK {
    var pointsA = [nutrimentScore]()
    var pointsC = [nutrimentScore]()
    var score = 0
    var level = NutritionalScoreLevel()
    
    
    // conclusion
    var total: Int {
        get {
            var sumA = 0
            for point in pointsA {
                sumA += point.points
            }
            let sumC = pointsC[0].points + pointsC[1].points

            if sumA < 11 {
                return sumA - sumC - pointsC[2].points
            } else {
                // nuts etc highest?
                if pointsC[0].points == 5 {
                    return sumA - sumC - pointsC[2].points
                } else {
                    // do not incorporate the proteins
                    return sumA - sumC
                }
            }
        }
    }

    struct nutrimentScore {
        var nutriment = ""
        var points = 0
    }
    
    struct Constants {
        static let energyKey = "energy"
        static let saturatedFatKey = "saturated-fat"
        static let saturatedFatRatioKey = "fr-sat-fat-for-fats"
        static let sugarsKey = "sugars"
        static let sodiumKey = "sodium"
        static let fruitsVegetablesNutsKey = "fruits-vegetables-nuts"
        static let fiberKey = "fiber"
        static let proteinsKey = "proteins"
    }
    
    init() {
        setup()
    }
    
    
    fileprivate mutating func setup() {
        let preferredLanguage = Locale.preferredLanguages[0]

        var energy = nutrimentScore()
        energy.nutriment = OFFplists.manager.translateNutrients(Constants.energyKey, language:preferredLanguage)
        energy.points = 0
        
        var saturatedFats = nutrimentScore()
        saturatedFats.nutriment = OFFplists.manager.translateNutrients(Constants.saturatedFatKey, language:preferredLanguage)
        saturatedFats.points = 0

        var sugars = nutrimentScore()
        sugars.nutriment = OFFplists.manager.translateNutrients(Constants.sugarsKey, language:preferredLanguage)
        sugars.points = 0
        
        var sodium = nutrimentScore()
        sodium.nutriment = OFFplists.manager.translateNutrients(Constants.sodiumKey, language:preferredLanguage)
        sodium.points = 0
        pointsA = [energy, saturatedFats, sugars, sodium]
        
        var fruitsVegetablesNuts = nutrimentScore()
        fruitsVegetablesNuts.nutriment = OFFplists.manager.translateNutrients(Constants.fruitsVegetablesNutsKey, language:preferredLanguage)
        fruitsVegetablesNuts.points = 0
        
        var fiber = nutrimentScore()
        fiber.nutriment = OFFplists.manager.translateNutrients(Constants.fiberKey, language:preferredLanguage)
        fiber.points = 0
        
        var proteins = nutrimentScore()
        proteins.nutriment = OFFplists.manager.translateNutrients(Constants.proteinsKey, language:preferredLanguage)
        proteins.points = 0
        pointsC = [fruitsVegetablesNuts, fiber, proteins]
        
    }
}
