//
//  NutriScoreFrance.swift
//  FoodViewer
//
//  Created by arnaud on 10/08/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//
/*
import Foundation
import UIKit

struct NutriScoreFrance {
    
    // Bron:
    // https://pdfs.semanticscholar.org/3d1c/c206bc286bb5f80452821a0d26ff9e55b387.pdf?_ga=2.97262294.8537200.1535095427-953204867.1535095427
    
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
            struct Fibre {
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
            struct FruitsVegetablesInBeverages {
                static let Table = [ (0, 0.0, 40.0),
                              (2, 40.0, 60.0),
                              (4, 60.0, 80.0),
                              (10, 80.0, 100.0)]
            }
        }
        static let LightGreen = UIColor.init(red: 0.56, green: 0.93, blue: 0.56, alpha: 1.0)
        static let DarkGreen = UIColor.init(red: 0.00, green: 0.2, blue: 0.3, alpha: 1.0)
    }
    
    private var energy: Double = 0.0
    private var sugars: Double = 0.0
    private var saturatedFat: Double = 0.0
    private var fat: Double = 0.0
    private var saturatedFatLipidRatio: Double {
        return saturatedFat / fat
    }
    private var sodium: Double = 0.0

    private var protein: Double = 0.0
    private var fruitVegetables: Double = 0.0
    private var fibre: Double = 0.0
    
    private var isBeverage = false
    private var isFat = false
    private var isWater = false
    private var isCheese = false

    var pointsA: Int {
        return energyPoints + sugarPoints + fatPoints + sodiumPoints
    }
    
    var energyPoints: Int {
        if isBeverage {
            return points(energy, in:Constant.PointsA.EnergyInBeverages.Table)
        } else {
            return points(energy, in:Constant.PointsA.Energy.Table)
        }
    }

    var sugarPoints: Int {
        if isBeverage {
            return points(sugars, in:Constant.PointsA.SugarsInBeverages.Table)
        } else {
            return points(sugars, in:Constant.PointsA.Sugars.Table)
        }
    }

    var fatPoints: Int {
        if isFat {
            return points(saturatedFat, in:Constant.PointsA.SaturatedFatToLipids.Table)
        } else {
            return points(saturatedFatLipidRatio, in:Constant.PointsA.SaturatedFat.Table)
        }
    }

    var sodiumPoints: Int {
        return points(sodium, in:Constant.PointsA.Sodium.Table)
    }

    var pointsC: Int {
        return proteinPoints
         + fibrePoints
         + fruitsVegetablesPoints
    }
    
    var proteinPoints: Int {
        return points(protein, in:Constant.PointsC.Protein.Table)
    }

    var fibrePoints: Int {
        return points(fibre, in:Constant.PointsC.Fibre.Table)
    }

    var fruitsVegetablesPoints: Int {
        if isBeverage {
            return points(fruitVegetables, in:Constant.PointsC.FruitsVegetablesInBeverages.Table)
        } else {
            return points(fruitVegetables, in:Constant.PointsC.FruitsVegetables.Table)
        }
    }
    
    init(energy:Double, sugars:Double, fat:Double, saturatedFat:Double, protein: Double, fibre:Double, fruitVegetables:Double, sodium:Double, isFat:Bool, isCheese: Bool, isBeverage:Bool, isWater: Bool) {
        self.energy = energy
        self.sugars = sugars
        self.fat = fat
        self.saturatedFat = saturatedFat
        self.protein = protein
        self.fibre = fibre
        self.fruitVegetables = fruitVegetables
        self.sodium = sodium
        self.isFat = isFat
        self.isCheese = isCheese
        self.isBeverage = isBeverage
        self.isWater = isWater
    }
    
    var score: Int {
        if pointsA < 11 || isCheese {
            return pointsA - pointsC
        } else {
            if fruitsVegetablesPoints == 5 {
                return pointsA - pointsC
            } else {
                return pointsA - (fibrePoints + fruitsVegetablesPoints)
            }
        }
    }
    
    var colour: UIColor {
        if isBeverage {
            if isWater { return Constant.LightGreen }
            if score <= 1 {
                return Constant.DarkGreen
            } else if score <= 5 {
                return .yellow
            } else if score <= 9 {
                return .orange
            } else {
                return .red
            }
        } else {
            if score <= -1 {
                return Constant.LightGreen
            } else if score <= 2 {
                return Constant.DarkGreen
            } else if score <= 10 {
                return .yellow
            } else if score <= 18 {
                return .orange
            } else {
                return .red
            }
        }
    }
    
    fileprivate func points(_ value:Double, in table: [(Int,Double,Double)]) -> Int {
        for row in table {
            if value > row.1 && value < row.2 {
                return row.0
            }
        }
        return 0
    }
    
}
*/
