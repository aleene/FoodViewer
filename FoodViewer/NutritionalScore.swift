//
//  NutritionalScore.swift
//  FoodViewer
//
//  Created by arnaud on 10/03/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

public class NutritionalScore {
    
    public var pointsA = [nutrimentScore]()
    public var pointsC = [nutrimentScore]()
    public var score = 0
    public var level = NutritionalScoreLevel()
    
    // conclusion
    public var total: Int {
        get {
            return sumA - sumC
        }
    }
    
    public struct nutrimentScore {
        public var nutriment = ""
        public var points = 0
    }

    public struct Constants {
        static let energyKey = "energy"
        static let sugarsKey = "sugars"
        static let sodiumKey = "sodium"
        static let fruitsVegetablesNutsKey = "fruits-vegetables-nuts"
        static let fiberKey = "fiber"
        static let proteinsKey = "proteins"
    }
    
    public init() {
        setup()
    }
    
    public var sumA: Int {
        get {
            return pointsA[0].points + pointsA[1].points + pointsA[2].points + pointsA[3].points
        }
    }
    
    private var sumC: Int {
        get {
            return pointsC[0].points + pointsC[1].points + pointsC[2].points
        }
    }

    private func setup() {
        
        var energy = nutrimentScore()
        energy.nutriment = Constants.energyKey
        
        let stub = nutrimentScore()
        
        var sugars = nutrimentScore()
        sugars.nutriment = Constants.sugarsKey
        
        var sodium = nutrimentScore()
        sodium.nutriment = Constants.sodiumKey
        
        pointsA = [energy, stub, sugars, sodium]
        
        var fruitsVegetablesNuts = nutrimentScore()
        fruitsVegetablesNuts.nutriment = Constants.fruitsVegetablesNutsKey
        
        var fiber = nutrimentScore()
        fiber.nutriment = Constants.fiberKey
        
        var proteins = nutrimentScore()
        proteins.nutriment = Constants.proteinsKey
        
        pointsC = [fruitsVegetablesNuts, fiber, proteins]
        
    }
}
