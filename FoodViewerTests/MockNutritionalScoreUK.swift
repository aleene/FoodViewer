//
//  MockNutritionalScoreUK.swift
//  FoodViewer
//
//  Created by arnaud on 09/03/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation
import FoodViewer

public struct MockNutritionalScoreUK {
    public var pointsA = [nutrimentScore]()
    public var pointsC = [nutrimentScore]()
    public var score = 0
    public var level = NutritionalScoreLevel()
    
    
    // conclusion
    public var total: Int {
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
    
    public struct nutrimentScore {
        public var nutriment = ""
        public var points = 0
    }
    
    private struct Constants {
        static let energyKey = "energy"
        static let saturatedFatKey = "saturated-fat"
        static let saturatedFatRatioKey = "fr-sat-fat-for-fats"
        static let sugarsKey = "sugars"
        static let sodiumKey = "sodium"
        static let fruitsVegetablesNutsKey = "fruits-vegetables-nuts"
        static let fiberKey = "fiber"
        static let proteinsKey = "proteins"
    }
    
    public init() {
        setup()
    }
    
    
    private mutating func setup() {
        
        //MOCKED let preferredLanguage = Locale.preferredLanguages[0]
        
        var energy = nutrimentScore()
        //MOCKED energy.nutriment = OFFplists.manager.translateNutrients(Constants.energyKey, language:preferredLanguage)
        energy.nutriment = Constants.energyKey
        energy.points = 0
        
        var saturatedFats = nutrimentScore()
        //MOCKED saturatedFats.nutriment = OFFplists.manager.translateNutrients(Constants.saturatedFatKey, language:preferredLanguage)
        saturatedFats.nutriment = Constants.saturatedFatKey
        saturatedFats.points = 0
        
        var sugars = nutrimentScore()
        //MOCKED sugars.nutriment = OFFplists.manager.translateNutrients(Constants.sugarsKey, language:preferredLanguage)
        sugars.nutriment = Constants.sugarsKey
        sugars.points = 0
        
        var sodium = nutrimentScore()
        //MOCKED sodium.nutriment = OFFplists.manager.translateNutrients(Constants.sodiumKey, language:preferredLanguage)
        sodium.nutriment = Constants.sodiumKey
        sodium.points = 0
        
        pointsA = [energy, saturatedFats, sugars, sodium]
        
        var fruitsVegetablesNuts = nutrimentScore()
        //MOCKED fruitsVegetablesNuts.nutriment = OFFplists.manager.translateNutrients(Constants.fruitsVegetablesNutsKey, language:preferredLanguage)
        fruitsVegetablesNuts.nutriment = Constants.fruitsVegetablesNutsKey
        fruitsVegetablesNuts.points = 0
        
        var fiber = nutrimentScore()
        //MOCKED fiber.nutriment = OFFplists.manager.translateNutrients(Constants.fiberKey, language:preferredLanguage)
        fiber.nutriment = Constants.fiberKey
        fiber.points = 0
        
        var proteins = nutrimentScore()
        //MOCKED proteins.nutriment = OFFplists.manager.translateNutrients(Constants.proteinsKey, language:preferredLanguage)
        proteins.nutriment = Constants.proteinsKey
        proteins.points = 0
        
        pointsC = [fruitsVegetablesNuts, fiber, proteins]
        
    }
}
