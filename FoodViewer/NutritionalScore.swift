//
//  NutritionalScore.swift
//  FoodViewer
//
//  Created by arnaud on 10/03/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

// Bron:
// https://www.researchgate.net/profile/Peter_Scarborough/publication/266447771_Nutrient_profiles_Development_of_Final_Model_Final_Report/links/5440d4fe0cf218719077d82d.pdf

// Note that this article takes into account a separate calculation for Beverages
// However it does not use separate tables for beverages

public class NutritionalScore {

// This data is taken from http://www.euro.who.int/__data/assets/pdf_file/0008/357308/PHP-1122-NutriScore-eng.pdf
    
    fileprivate struct Constant {
        struct PointsA {
            struct Energy {
                static let Table = [ (0,   0.0, 335.0),
                                     (1, 335.0, 670.0),
                                     (2, 670.0, 1005.0),
                                     (3, 1005.0, 1340.0),
                                     (4, 1340.0, 1675.0),
                                     (5, 1675.0, 2010.0),
                                     (6, 2010.0, 2345.0),
                                     (7, 2345.0, 2680.0),
                                     (8, 2680.0, 3015.0),
                                     (9, 3015.0, 3350.0),
                                     (10, 3350, 999999999.0)]
            }
            struct SaturatedFat {
                static let Table = [ (0, 0.0, 1.0),
                                     (1, 1.0, 2.0),
                                     (2, 2.0, 3.0),
                                     (3, 3.0, 4.0),
                                     (4, 4.0, 5.0),
                                     (5, 5.0, 6.0),
                                     (6, 6.0, 7.0),
                                     (7, 7.0, 8.0),
                                     (8, 8.0, 9.0),
                                     (9, 9.0, 10.0),
                                     (10, 10.0, 100.0) ]
            }
            struct Sugars {
                static let Table = [ (0, 0.0, 4.5),
                                     (1, 4.5, 9.0),
                                     (2, 9.0, 13.5),
                                     (3, 13.5, 18.0),
                                     (4, 18.0, 22.5),
                                     (5, 22.5, 27.0),
                                     (6, 27.0, 31.0),
                                     (7, 31.0, 36.0),
                                     (8, 36.0, 40.0),
                                     (9, 40.0, 45.0),
                                     (10, 45.0, 100.0)]
            }
            struct Sodium {
                static let Table = [ (0, 0.00, 0.09),
                                     (1, 0.09, 0.18),
                                     (2, 0.18, 0.27),
                                     (3, 0.27, 0.36),
                                     (4, 0.36, 0.45),
                                     (5, 0.45, 0.54),
                                     (6, 0.54, 0.63),
                                     (7, 0.63, 0.72),
                                     (8, 0.72, 0.81),
                                     (9, 0.81, 0.90),
                                     (10, 0.90, 1.0)]
            }
        }
        
        struct PointsC {
            struct Protein {
                static let Table = [ (0, 0.0, 1.6),
                                     (1, 1.6, 3.2),
                                     (2, 3.2, 4.8),
                                     (3, 4.8, 6.4),
                                     (4, 6.4, 8.0),
                                     (5, 8.0, 100.0)]
            }
            struct Fiber {
                static let Table = [ (0, 0.0, 0.7),
                                     (1, 0.7, 1.4),
                                     (2, 1.4, 2.1),
                                     (3, 2.1, 2.8),
                                     (4, 2.8, 3.5),
                                     (5, 3.5, 100.0)]
            }
            struct FruitsVegetables {
                static let Table = [ (0, 0.0, 40.0),
                                     (1, 40.0, 60.0),
                                     (2, 60.0, 80.0),
                                     (5, 80.0, 100.0)]
            }
        }
        static let LightGreen = UIColor.init(red: 0.56, green: 0.93, blue: 0.56, alpha: 1.0)
        static let DarkGreen = UIColor.init(red: 0.00, green: 0.2, blue: 0.3, alpha: 1.0)
    }

    public struct Key {
        struct Category {
            static let Beverages = ["en:tea-based-beverages",
                                    "en:iced-teas",
                                    "en:herbal-tea-beverages",
                                    "coffee-beverages",
                                    "herbal-teas"]
            static let Cheeses = ["en:cheeses"]
            static let Fats = ["en:fats"]
        }
        static let PositiveNutrients = [Nutrient.energy, Nutrient.saturatedFat, Nutrient.saturatedFatRatio, Nutrient.sugars, Nutrient.sodium]
        static let NegativeNutrients = [Nutrient.fiber, Nutrient.proteins, Nutrient.fruitsVegetablesNuts, Nutrient.fruitsVegetablesNutsEstimate]
    }
    

    // The arrays with A and C points are filled,
    // The NutrimentScores are nil, in order to detect whether a value is set or not
    public var pointsA: [String:NutrimentScore?] = [Nutrient.energy.key:nil,
                                                    Nutrient.saturatedFat.key:nil,
                                                    Nutrient.sugars.key:nil,
                                                    Nutrient.sodium.key:nil ]

    public var pointsC: [String:NutrimentScore?] = [Nutrient.fiber.key:nil,
                                                    Nutrient.proteins.key:nil,
                                                    Nutrient.fruitsVegetablesNuts.key:nil,
                                                    Nutrient.fruitsVegetablesNutsEstimate.key:nil]
    public var score = 0
    
    public var level = NutritionalScoreLevel()
    
    // Simple
    public var total: Int? {
        // If a food or drink scores 11 or more ‘A’ points
         if sumA < 11 {
            return sumA - sumC
        } else {
        // then it can not score points for protein unless it also scores 5 points for fruit, veg and nuts
            if let fruitVegetableNuts = pointsC[Nutrient.fruitsVegetablesNuts.key],
                let fruitVegetableNutsValue = fruitVegetableNuts {
                // If a food or drink scores 5 points for fruit, veg & nuts the ‘A’ nutrient cut-off no longer applies.
                if fruitVegetableNutsValue.points == 5 {
                    // use all C points
                    return sumA - sumC
                } else {
                    return sumA - ( pointsC[Nutrient.fiber.key]??.points ?? 0 ) - fruitVegetableNutsValue.points
                }
            } else if let fiberNutrimentScore = pointsC[Nutrient.fiber.key],
                let validFiberNutrimentScore = fiberNutrimentScore {
                // use only fiber points
                return sumA - validFiberNutrimentScore.points
            }
        }
        return sumA
    }
    
    public struct NutrimentScore {
        public var points = 0
        public var value: Double? = nil
    }

    
    public var sumA: Int {
        get {
            var sum = 0
            if let element = pointsA[Nutrient.energy.key],
                let elementWithData = element {
                sum += elementWithData.points
            }
            if let element = pointsA[Nutrient.saturatedFat.key],
                let elementWithData = element {
                sum += elementWithData.points
            }
            if let element = pointsA[Nutrient.sugars.key],
                let elementWithData = element {
                sum += elementWithData.points
            }
            if let element = pointsA[Nutrient.sodium.key],
                let elementWithData = element {
                sum += elementWithData.points
            }
            return sum
        }
    }
    
    public var sumC: Int {
        get {
            var sum = 0
            if let element = pointsC[Nutrient.fiber.key],
                let elementWithData = element {
                sum += elementWithData.points
            }
            if let element = pointsC[Nutrient.proteins.key],
                let elementWithData = element {
                sum += elementWithData.points
            }
            if let element = pointsC[Nutrient.fruitsVegetablesNuts.key],
                let elementWithData = element {
                sum += elementWithData.points
            }

            return sum
        }
    }
    
    public var decodedScore: Int? = nil
    
    public var isCovered = false

    public var isMissing: Bool? = nil   

    public var colour: UIColor {
        if score <= -1 {
            if #available(iOS 11.0, *) {
                return UIColor.init(named: "LightGreen") ?? .systemGreen
            } else {
                return Constant.LightGreen
            }

        } else if score <= 2 {
            if #available(iOS 11.0, *) {
                return UIColor.init(named: "DarkGreen") ?? .systemGreen
            } else {
                return Constant.DarkGreen
            }
        } else if score <= 10 {
            return .systemYellow
        } else if score <= 18 {
            return .systemOrange
        } else {
            return .systemRed
        }
    }
    
    public var sortedPointsA: [(String, NutritionalScore.NutrimentScore?)] {
        var array: [(String, NutritionalScore.NutrimentScore?)] = []
        for nutrient in Key.PositiveNutrients {
            if let point = pointsA[nutrient.key] {
                array.append((nutrient.key, point))
            }
        }
        return array
    }
    
    public var sortedPointsC: [(String, NutritionalScore.NutrimentScore?)] {
        var array: [(String, NutritionalScore.NutrimentScore?)] = []
        for nutrient in Key.NegativeNutrients {
            if let point = pointsC[nutrient.key] {
                array.append((nutrient.key, point))
            }
        }
        return array
    }

    //
    // MARK: - Initialisers
    //
    
    init() {
    }

    init(energy: Double?, saturatedFat: Double?, sugars: Double?, sodium: Double?, fruitVegetablesNuts: Double?, fruitVegetablesNutsEstimated: Double?, fiber: Double?, proteins: Double?) {
        var nutrimentScore = NutrimentScore()

        if let validEnergy = energy {
            nutrimentScore.value = validEnergy
            nutrimentScore.points = points(validEnergy, in:Constant.PointsA.Energy.Table)
            pointsA[Nutrient.energy.key] = nutrimentScore
        }
        
        if let validSaturatedFat = saturatedFat {
            nutrimentScore.value = validSaturatedFat
            nutrimentScore.points = points(validSaturatedFat, in:Constant.PointsA.Sugars.Table)
            pointsA[Nutrient.saturatedFat.key] = nutrimentScore
        }

        if let validSugars = sugars {
            nutrimentScore.value = validSugars
            nutrimentScore.points = points(validSugars, in:Constant.PointsA.Sugars.Table)
            pointsA[Nutrient.sugars.key] = nutrimentScore
        }
        
        if let validSodium = sodium {
            nutrimentScore.value = validSodium
            nutrimentScore.points = points(validSodium, in:Constant.PointsA.Sodium.Table)
            pointsA[Nutrient.sodium.key] = nutrimentScore
        }
        
        if let validFruitVegetableNuts = fruitVegetablesNutsEstimated {
            nutrimentScore.value = validFruitVegetableNuts
            nutrimentScore.points = points(validFruitVegetableNuts, in:Constant.PointsC.FruitsVegetables.Table)
            pointsC[Nutrient.fruitsVegetablesNutsEstimate.key] = nutrimentScore
        }
    
        if let validFruitVegetableNuts = fruitVegetablesNuts {
            nutrimentScore.value = validFruitVegetableNuts
            nutrimentScore.points = points(validFruitVegetableNuts, in:Constant.PointsC.FruitsVegetables.Table)
            pointsC[Nutrient.fruitsVegetablesNuts.key] = nutrimentScore
        }

        if let validFiber = fiber {
            nutrimentScore.value = validFiber
            nutrimentScore.points = points(validFiber, in:Constant.PointsC.Fiber.Table)
            pointsC[Nutrient.fiber.key] = nutrimentScore
        }
        
        if let validProteins = proteins {
            nutrimentScore.value = validProteins
            nutrimentScore.points = points(validProteins, in:Constant.PointsC.Protein.Table)
            pointsC[Nutrient.proteins.key] = nutrimentScore
        }
    }
    
    init(energyPoints: Int?, saturatedFatPoints: Int?, sugarPoints: Int?, sodiumPoints: Int?, fruitVegetablesNutsPoints: Int?, fiberPoints: Int?, proteinPoints: Int?) {
        var nutrimentScore = NutrimentScore()
        
        if let validEnergyPoints = energyPoints {
            nutrimentScore.points = validEnergyPoints
            pointsA[Nutrient.energy.key] = nutrimentScore
        }
            
        if let validSaturatedFatPoints = saturatedFatPoints {
            nutrimentScore.points = validSaturatedFatPoints
            pointsA[Nutrient.saturatedFat.key] = nutrimentScore
        }

        if let validSugarPoints = sugarPoints {
            nutrimentScore.points = validSugarPoints
            pointsA[Nutrient.sugars.key] = nutrimentScore
        }

        if let validSodiumPoints = sodiumPoints {
            nutrimentScore.points = validSodiumPoints
            pointsA[Nutrient.sodium.key] = nutrimentScore
        }
        if let validFruitVegetablesNutsPoints = fruitVegetablesNutsPoints {
            nutrimentScore.points = validFruitVegetablesNutsPoints
            pointsC[Nutrient.fruitsVegetablesNuts.key] = nutrimentScore
        }
        if let validFiberPoints = fiberPoints {
            nutrimentScore.points = validFiberPoints
            pointsC[Nutrient.fiber.key] = nutrimentScore
        }
        if let validProteinPoints = proteinPoints {
            nutrimentScore.points = validProteinPoints
            pointsC[Nutrient.proteins.key] = nutrimentScore
        }

    }
    
    convenience init(energy: Double?, saturatedFat: Double?, sugars: Double?, salt: Double?, fruitVegetablesNuts: Double?, fruitVegetablesNutsEstimated: Double?, fiber: Double?, proteins: Double?) {
        
        // The sodium content corresponds to the salt content listed in the mandatory declaration divided by a conversion coefficient of 2.5.
        
        var sodium:Double? = nil
        if let validSalt = salt {
            sodium = validSalt / 2.5
        }
        self.init(energy: energy, saturatedFat: saturatedFat, sugars: sugars, sodium: sodium, fruitVegetablesNuts: fruitVegetablesNuts, fruitVegetablesNutsEstimated: fruitVegetablesNutsEstimated, fiber: fiber, proteins: proteins)
    }
    
    convenience init(nutritionFactsDict: [String:NutritionFactItem]) {
        
        
        var energy: Double? = nil
        var sugars: Double? = nil
        var saturatedFat: Double? = nil
        var sodium: Double? = nil
        var fiber: Double? = nil
        var proteins: Double? = nil
        var fruitVegetableNuts: Double? = nil
        var fruitVegetableNutsEstimated: Double? = nil
        
        if let nutrientFact = nutritionFactsDict[Nutrient.energy.key] {
            energy = nutrientFact.standardAsDouble
        }
        if let nutrientFact = nutritionFactsDict[Nutrient.sugars.key] {
            sugars = nutrientFact.gramValue
        }
        if let nutrientFact = nutritionFactsDict[Nutrient.saturatedFat.key] {
            saturatedFat = nutrientFact.gramValue
        }
        if let nutrientFact = nutritionFactsDict[Nutrient.sodium.key] {
            sodium = nutrientFact.gramValue
        }
        if let nutrientFact = nutritionFactsDict[Nutrient.fiber.key] {
            fiber = nutrientFact.gramValue
        }
        if let nutrientFact = nutritionFactsDict[Nutrient.proteins.key] {
            proteins = nutrientFact.gramValue
        }
        if let nutrientFact = nutritionFactsDict[Nutrient.fruitsVegetablesNuts.key] {
            fruitVegetableNuts = nutrientFact.gramValue
        }
        if let nutrientFact = nutritionFactsDict[Nutrient.fruitsVegetablesNutsEstimate.key] {
            fruitVegetableNutsEstimated = nutrientFact.gramValue
        }
        
        self.init(energy: energy, saturatedFat: saturatedFat, sugars: sugars, sodium: sodium, fruitVegetablesNuts: fruitVegetableNuts, fruitVegetablesNutsEstimated: fruitVegetableNutsEstimated, fiber: fiber, proteins: proteins)
        
    }

    //
    // MARK: - Private variables and functions
    //
    
    private var energy: Double = 0.0
    private var sugar: Double = 0.0
    private var sodium: Double = 0.0
    private var fibre: Double = 0.0
    private var saturatedFat: Double = 0.0
    private var fruitVegetablesNuts: Double = 0.0
    private var protein: Double = 0.0

    fileprivate func points(_ value:Double, in table: [(Int,Double,Double)]) -> Int {
        for row in table {
            if value >= row.1 && value < row.2 {
                return row.0
            }
        }
        return 0
    }

    
}
