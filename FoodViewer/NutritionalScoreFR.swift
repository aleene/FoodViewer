//
//  NutritionalScoreFR.swift
//  FoodViewer
//
//  Created by arnaud on 11/06/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//
// This class implements the exceptions of the UK NutriScore

import Foundation
import UIKit

public class NutritionalScoreFR: NutritionalScore {

// This data is taken from http://www.euro.who.int/__data/assets/pdf_file/0008/357308/PHP-1122-NutriScore-eng.pdf
    // The calculation method from France uses:
    // - special tables for beverages
    // - puts water always in score A
    // - a special calculation method for cheese
    // - a special calculation method for added fats
    
    private static let Keys = ["en:baby-foods",
                               "en:baby-milks",
                               "en:meal-replacements",
                               "en:alcoholic-beverages",
                               "en:coffees",
                               "en:food-additives",
                               "en:teas",
                               "en:herbal-teas",
                               "en:yeasts",
                               "fr:levure",
                               "fr:levures", "fr:Levures",
                               "en:honeys",
                               "en:vinegars",
                               "en:pet-food",
                               "en:non-food-products"]
    // Food products that are not covered by the mandatory nutritional declaration are listed in Appendix V of regulation no. 1169/2011. They are:
    //1. Unprocessed products that comprise a single ingredient or category of ingredients (such as fresh fruits or vegetables, cut raw meat, honey, etc.)
    //2. Processed products where the only processing they have been subjected to is maturing and that comprise a single ingredient or category of ingredients
    //Note: here the products in question are mainly meat products
    //3. Waters intended for human consumption, including those where the only added ingredients are carbon dioxide and/or flavourings
    //4. Herbs, spices or mixtures thereof
    //5. Salt and salt substitutes
    //6. Table top sweeteners
    //7. Products covered by Directive 1999/4/EC of the European Parliament and of the Council of 22
    //February 1999 relating to coffee extracts and chicory extracts, whole or milled coffee beans, and
    //whole or milled decaffeinated coffee beans
    //8. Herbal and fruit infusions, tea, decaffeinated tea, instant or soluble tea or tea extract, decaffeinated
    //instant or soluble tea or tea extract, which do not contain other added ingredients than flavourings
    //which do not modify the nutritional value of the tea
    //9. Fermented vinegars and substitutes for vinegar, including those where the only added ingredients are flavourings
    //10. Flavourings
    //11. Food additives
    //12. Processing aids
    //13. Food enzymes
    //14. Gelatine
    //15. Jam setting compounds
    //16. Yeasts
    //17. Chewing gums
    //18. Food in packaging or containers the largest surface of which has an area of less than 25 cm2
    //19. Food, including handcrafted food, directly supplied by the manufacturer of small quantities of products to the final consumer or to local retail establishments directly supplying the final consumer


    fileprivate struct Constant {
        struct PointsA {
            struct SaturatedFatToLipids {
                static let Table = [ (0,  0.0, 10.0),
                                     (1, 10.0, 16.0),
                                     (2, 16.0, 22.0),
                                     (3, 22.0, 28.0),
                                     (4, 28.0, 34.0),
                                     (5, 34.0, 40.0),
                                     (6, 40.0, 46.0),
                                     (7, 46.0, 52.0),
                                     (8, 52.0, 58.0),
                                     (9, 58.0, 64.0),
                                     (10, 64.0, 100.0) ]
            }
            struct EnergyInBeverages {
                static let Table = [ (0,  0.0,  0.0),
                                     (1,  0.0, 30.0),
                                     (2, 30.0, 60.0),
                                     (3, 60.0, 90.0),
                                     (4, 90.0, 120.0),
                                     (5, 120.0, 150.0),
                                     (6, 150.0, 180.0),
                                     (7, 180.0, 210.0),
                                     (8, 210.0, 240.0),
                                     (9, 240.0, 270.0),
                                     (10, 270.0, 999999999.0)]
            }
            struct SugarsInBeverages {
                static let Table = [ (0, 0.0, 0.0),
                                     (1, 0.0, 1.5),
                                     (2, 1.5, 3.0),
                                     (3, 3.0, 4.5),
                                     (4, 4.5, 6.0),
                                     (5, 6.0, 7.5),
                                     (6, 7.5, 9.0),
                                     (7, 9.0, 10.5),
                                     (8, 10.5, 12.0),
                                     (9, 12.0, 13.5),
                                     (10, 13.5, 100.0)]
            }
        }
        struct PointsC {
            struct FruitsVegetablesInBeverages {
                static let Table = [ (0, 0.0, 40.0),
                                     (2, 40.0, 60.0),
                                     (4, 60.0, 80.0),
                                     (10, 80.0, 100.0)]
            }
        }
    }
    
    public var isFat = false
    public var isCheese = false
    public var isBeverage = false
    public var isWater = false

    public struct ThisClassKey {
        static let SaturatedFatRatio = "fr-sat-fat-for-fats"
    }
    
    public var isAvailable = true
    
    /// The  NutriScore part the score falls in
    override public var nutriScoreLabelPart: NutriScoreLabelPart {
        if isBeverage {
            if isWater {
                return .first
            }
            if score <= 1 {
                return .second
            } else if score <= 5 {
                return .third
            } else if score <= 9 {
                return .fourth
            } else {
                return .fifth
            }
        } else {
            if score <= -1 {
                return .first
            } else if score <= 2 {
                return .second
            } else if score <= 10 {
                return .third
            } else if score <= 18 {
                return .fourth
            } else {
                return .fifth
            }
        }
    }
    
    /// Calculated NutriScore
    override public var total: Int? {
        get {
            if sumA < 11 || isCheese {
                return super.sumA - super.sumC
            } else {
                // then it can not score points for protein unless it also scores 5 points for fruit, veg and nuts
                if let fruitVegetableNuts = pointsC[Nutrient.fruitsVegetablesNuts.key],
                    let fruitVegetableNutsValue = fruitVegetableNuts {
                    // If a food or drink scores 5 points for fruit, veg & nuts the ‘A’ nutrient cut-off no longer applies.
                    if fruitVegetableNutsValue.points == 5 {
                        // use all C points
                        return super.sumA - super.sumC
                    } else {
                        if let fiber = pointsC[Nutrient.fiber.key],
                            let fiberValue = fiber {
                            //use fiber and fruitVegetableNut points
                            return super.sumA - (fiberValue.points + fruitVegetableNutsValue.points)
                        } else {
                            //use only fruitVegetableNut points
                            return super.sumA - fruitVegetableNutsValue.points
                        }
                    }
                } else if let fiberNutrimentScore = pointsC[Nutrient.fiber.key],
                    let validFiberNutrimentScore = fiberNutrimentScore {
                    // use only fiber points
                    return super.sumA - validFiberNutrimentScore.points
                }
            }
            return super.sumA
        }
    }
//
// MARK: - Initialisers
//
    init(isAvailable:Bool) {
        super.init()
        self.isAvailable = isAvailable
    }

    init(isMissing:Bool) {
        super.init()
        self.isMissing = isMissing
    }

    init(energy: Double?, saturatedFat: Double?, saturatedFatToTotalFatRatio: Double?, sugars: Double?, sodium: Double?, fiber: Double?, proteins: Double?, fruitsVegetableNuts: Double?, fruitsVegetableNutsEstimated: Double?, isBeverage: Bool, isFat: Bool, isCheese: Bool) {
        super.init(energy: energy, saturatedFat: saturatedFat, sugars: sugars, sodium: sodium, fruitVegetablesNuts: fruitsVegetableNuts, fruitVegetablesNutsEstimated: fruitsVegetableNutsEstimated, fiber: fiber, proteins: proteins)
        
        
        self.isFat = isFat
        self.isCheese = isCheese
        self.isBeverage = isBeverage

        var nutrimentScore = NutrimentScore()
        
        // If it is a beverage apply the extra tables
        if isBeverage {
            if let validEnergy = energy {
                nutrimentScore.value = validEnergy
                nutrimentScore.points = points(validEnergy, in:Constant.PointsA.EnergyInBeverages.Table)
                pointsA[Nutrient.energy.key] = nutrimentScore
            }
            
            if let validSugars = sugars {
                nutrimentScore.value = validSugars
                nutrimentScore.points = points(validSugars, in:Constant.PointsA.SugarsInBeverages.Table)
                pointsA[Nutrient.sugars.key] = nutrimentScore
            }
            
            if let validFruitsVegetableNuts = fruitsVegetableNuts {
                nutrimentScore.value = validFruitsVegetableNuts
                nutrimentScore.points = points(validFruitsVegetableNuts, in:Constant.PointsC.FruitsVegetablesInBeverages.Table)
                pointsC[Nutrient.fruitsVegetablesNuts.key] = nutrimentScore
            }
            
            /*
             // Any estimate value is translated/processed to a true value
            if let validFruitsVegetableNuts = fruitsVegetableNutsEstimated {
                nutrimentScore.value = validFruitsVegetableNuts
                nutrimentScore.points = points(validFruitsVegetableNuts, in:Constant.PointsC.FruitsVegetablesInBeverages.Table)
                pointsC[Nutrient.fruitsVegetablesNutsEstimate.key] = nutrimentScore
            }
 */
        }
        
        // 'Added fats' refer to fats sold as finished products, not to fats used as ingredients in a recipe. For instance, the following are considered added fats: vegetable oils, margarines, butter, cream or dairy products used as added fats.
        
        if isFat {
            if let validSaturatedFatTotalFatRatio = saturatedFatToTotalFatRatio {
                nutrimentScore.value = validSaturatedFatTotalFatRatio
                nutrimentScore.points = points(validSaturatedFatTotalFatRatio, in:Constant.PointsA.SaturatedFatToLipids.Table)
                pointsA.removeValue(forKey: Nutrient.saturatedFat.key)
                pointsA[Nutrient.saturatedFatRatio.key] = nutrimentScore
            } else {
                pointsA[Nutrient.saturatedFatRatio.key] = nil
            }
        } else {
            pointsA.removeValue(forKey: Nutrient.saturatedFatRatio.key)
        }
    }
    
/// Initialise with points
    init(energyPoints: Int?, saturatedFatPoints: Int?, saturatedFatToTotalFatRatioPoints: Int?, sugarPoints: Int?, sodiumPoints: Int?, fiberPoints: Int?, proteinPoints: Int?, fruitsVegetableNutsPoints: Int?, fruitsVegetableNutsEstimatedPoints: Int?, isBeverage: Bool, isFat: Bool, isCheese: Bool) {
        super.init(energyPoints: energyPoints, saturatedFatPoints: saturatedFatPoints, sugarPoints: sugarPoints, sodiumPoints: sodiumPoints, fruitVegetablesNutsPoints: fruitsVegetableNutsPoints, fiberPoints: fiberPoints, proteinPoints: proteinPoints)
        
        self.isFat = isFat
        self.isCheese = isCheese
        self.isBeverage = isBeverage
        
        var nutrimentScore = NutrimentScore()
        
        // If it is a beverage apply the extra tables
        if isBeverage {
            if let validEnergyPoints = energyPoints {
                nutrimentScore.points = validEnergyPoints
                pointsA[Nutrient.energy.key] = nutrimentScore
            }
            
            if let validSugarPoints = sugarPoints {
                nutrimentScore.points = validSugarPoints
                pointsA[Nutrient.sugars.key] = nutrimentScore
            }
            
            if let validFruitsVegetableNutsPoints = fruitsVegetableNutsPoints {
                nutrimentScore.points = validFruitsVegetableNutsPoints
                pointsC[Nutrient.fruitsVegetablesNuts.key] = nutrimentScore
            }
        }
        
        if isFat {
            if let validSaturatedFatTotalFatRatioPoints = saturatedFatToTotalFatRatioPoints {
                nutrimentScore.points = validSaturatedFatTotalFatRatioPoints
                pointsA.removeValue(forKey: Nutrient.saturatedFat.key)
                pointsA[ThisClassKey.SaturatedFatRatio] = nutrimentScore
            } else {
                pointsA[ThisClassKey.SaturatedFatRatio] = nil
            }
        } else {
            pointsA.removeValue(forKey: ThisClassKey.SaturatedFatRatio)
        }
    }
    
    convenience init(nutritionFactsDict: [String:NutritionFactItem], taxonomy: Tags) {
    
        var isBeverage = false
        var isFat = false
        var isCheese = false
        
        switch taxonomy {
        case .available(let list):

            for key in Key.Category.Beverages {
                if list.contains(key) {
                    isBeverage = true
                    break
                }
            }
            for key in Key.Category.Fats {
                if list.contains(key) {
                    isFat = true
                    break
                }
            }
            for key in Key.Category.Cheeses {
                if list.contains(key) {
                    isCheese = true
                    break
                }
            }
        default:
            // The categories are not defined
            break
        }
        
        
        var energy: Double? = nil
        var sugars: Double? = nil
        var saturatedFat: Double? = nil
        var saturatedFatRatio: Double? = nil
        var sodium: Double? = nil
        var fiber: Double? = nil
        var proteins: Double? = nil
        var fruitVegetableNuts: Double? = nil
        var fruitVegetableNutsEstimated: Double? = nil

        if let nutrientFact = nutritionFactsDict[Nutrient.energy.key] {
            energy = nutrientFact.standardAsDouble
        }
        if let nutrientFact = nutritionFactsDict[Nutrient.sugars.key] {
            sugars = nutrientFact.standardGramValue
        }
        if let nutrientFact = nutritionFactsDict[Nutrient.saturatedFat.key] {
            saturatedFat = nutrientFact.standardGramValue
        }
        if let nutrientFact = nutritionFactsDict[Nutrient.saturatedFatRatio.key] {
            saturatedFatRatio = nutrientFact.standardGramValue
        }
        if let nutrientFact = nutritionFactsDict[Nutrient.sodium.key] {
            sodium = nutrientFact.standardGramValue
        }
        if let nutrientFact = nutritionFactsDict[Nutrient.fiber.key] {
            fiber = nutrientFact.standardGramValue
        }
        if let nutrientFact = nutritionFactsDict[Nutrient.proteins.key] {
            proteins = nutrientFact.standardGramValue
        }
        if let nutrientFact = nutritionFactsDict[Nutrient.fruitsVegetablesNuts.key] {
            fruitVegetableNuts = nutrientFact.standardGramValue
        }
        //if let nutrientFact = nutritionFactsDict[Nutrient.fruitsVegetablesNutsEstimate.key] {
        //    fruitVegetableNutsEstimated = nutrientFact.standardGramValue
        //}

        self.init(energy: energy, saturatedFat: saturatedFat, saturatedFatToTotalFatRatio: saturatedFatRatio, sugars: sugars, sodium: sodium, fiber: fiber, proteins: proteins, fruitsVegetableNuts: fruitVegetableNuts, fruitsVegetableNutsEstimated: fruitVegetableNutsEstimated, isBeverage: isBeverage, isFat: isFat, isCheese: isCheese)
        
        switch taxonomy {
        case .available(let list):
            isAvailable = isCovered(list)
        default:
            break
        }

    }
    
    override public var description: String {
        var string = "score: " + "\(score); "
        string += "total: " + (total != nil ? "\(total!); ": "nil; ")
        string += "sumA: " + "\(sumA); "
        string += "sumC: " + "\(sumC); "
        string += "energy :" + (pointsA[Nutrient.energy.key]??.points != nil ? "\(pointsA[Nutrient.energy.key]!!.points); " : "nil; ")
        string += "saturated fat :" + (pointsA[Nutrient.saturatedFat.key]??.points != nil ? "\(pointsA[Nutrient.saturatedFat.key]!!.points); " : "nil; ")
        string += "sugars :" + (pointsA[Nutrient.sugars.key]??.points != nil ? "\(pointsA[Nutrient.sugars.key]!!.points);" : "nil; ")
        string += "sodium :" + (pointsA[Nutrient.sodium.key]??.points != nil ? "\(pointsA[Nutrient.sodium.key]!!.points); " : "nil; ")
        string += "fiber :" + (pointsC[Nutrient.fiber.key]??.points != nil ? "\(pointsC[Nutrient.fiber.key]!!.points);" : "nil; ")
        string += "proteins :" + (pointsC[Nutrient.proteins.key]??.points != nil ? "\(pointsC[Nutrient.proteins.key]!!.points);" : "nil; ")
        string += "fruits+ :" + (pointsC[Nutrient.fruitsVegetablesNuts.key]??.points != nil ? "\(pointsC[Nutrient.fruitsVegetablesNuts.key]!!.points);" : "nil; ")
        string += "isBeverage: " + (isBeverage ? "YES" : "NO")
        string += "isCheese: " + (isCheese ? "YES" : "NO")
        string += "isFat: " + (isFat ? "YES" : "NO")
        return string
    }


    //
    // MARK: - Private functions and variables
    //

    fileprivate func points(_ value:Double, in table: [(Int,Double,Double)]) -> Int {
        for row in table {
            if value > row.1 && value < row.2 {
                return row.0
            }
        }
        return 0
    }

    public func isCovered(_ keys: [String]) -> Bool {
        for key in keys {
            if NutritionalScoreFR.Keys.contains(key) {
                return false
            }
        }
        return true
    }
}
