//
//  OFFProductNutriScoreData.swift
//  FoodViewer
//
//  Created by arnaud on 27/02/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import Foundation

class OFFProductNutriScoreData: Codable {
        
/*
         Sample JSON-part:
         
"nutriscore_data":{
    "energy":1660
    "energy_points":4,
    "energy_value":1660,
    "fiber":0,
    "fiber_points":0,
    "fiber_value":0,
    "fruits_vegetables_nuts_colza_walnut_olive_oils":0,
    "fruits_vegetables_nuts_colza_walnut_olive_oils_points":0,
    "fruits_vegetables_nuts_colza_walnut_olive_oils_value":0,
    "proteins":8.97,
    "proteins_points":5,
    "proteins_value":8.97,
    "sodium":819,
    "sodium_points":9,
    "sodium_value":819,
    "saturated_fat":1.28,
    "saturated_fat_points":1,
    "saturated_fat_value":1.3,
    "saturated_fat_ratio":14.2697881828317,
    "saturated_fat_ratio_points":1,
    "saturated_fat_ratio_value":14.3,
    "sugars":12.8,
    "sugars_points":2,
    "sugars_value":12.8,
    "is_beverage":0,
    "is_cheese":0,
    "is_fat":0,
    "is_water":0,
    "negative_points":16,
    "positive_points":0,
    "grade":"d",
    "score":16,
},
*/
        
    var nutriscore: NutritionalScoreFR? = nil

    struct DetailedKeys : CodingKey {
        var stringValue: String
            
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
            
        var intValue: Int? { return nil }
            
        init?(intValue: Int) { return nil }
    }
        
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DetailedKeys.self)
        //var foundString: String? = nil
        var foundInt: Int? = nil
        //var foundDouble: Double? = nil
        
        // The variables that we are looking for
        var energy: Int? = nil
        var saturatedFat: Int? = nil
        var saturatedFatToTotalFatRatio: Int? = nil
        var sugars: Int? = nil
        var sodium: Int? = nil
        var fiber: Int? = nil
        var proteins: Int? = nil
        var fruitsVegetableNuts: Int? = nil
        // var fruitsVegetableNutsEstimated: Int? = nil
        var isBeverage = false
        var isFat = false
        var isCheese = false

        for key in container.allKeys {
            do {
                // String entries are not use at the moment
                _ = try container.decode(String.self, forKey: key)
            } catch {
                do {
                    let name = try container.decode(Int.self, forKey: key)
                    foundInt = name
                } catch {
                    do {
                        let _ = try container.decode(Double.self, forKey: key)
                        // foundDouble = name
                    } catch {
                        print("OFFProductNutriScoreData: \(key) not convertable")
                    }
                }
            }
            switch key.stringValue {
            //case   "energy":
            case   "energy_points":
                energy = foundInt
            //case   "energy_value":
                
            //case  "fiber":
            case  "fiber_points":
                fiber = foundInt!
            //case   "fiber_value":
                
            //case  "proteins":
            case  "proteins_points":
                proteins = foundInt
            //case  "proteins_value":
            //case  "sodium":
            case   "sodium_points":
            if foundInt != nil {
                sodium = foundInt!
            }
            //case "sodium_value":
            //case   "saturated_fat":
            case   "saturated_fat_points":
                saturatedFat = foundInt
            //case   "saturated_fat_value":
                
            //case  "saturated_fat_ratio":
            case  "saturated_fat_ratio_points":
                saturatedFatToTotalFatRatio = foundInt
            //case  "saturated_fat_ratio_value":
                
            //case  "sugars":
            case   "sugars_points":
                sugars = foundInt
            //case   "sugars_value":
            case   "fruits_vegetables_nuts_colza_walnut_olive_oils_points":
                fruitsVegetableNuts = foundInt
            //case  "fruits_vegetables_nuts_colza_walnut_olive_oils_value":
            //case   "fruits_vegetables_nuts_colza_walnut_olive_oils":
            //case "fruits_vegetables_nuts_colza_walnut_olive_oils_estimate_points":
                // fruitsVegetableNutsEstimated = foundInt
                case  "is_beverage":
                    if foundInt != nil,
                        foundInt! == 1 {
                        isBeverage = true
                    }
                case   "is_cheese":
                    if foundInt != nil,
                        foundInt! == 1 {
                        isCheese = true
                    }
                case  "is_fat":
                    if foundInt != nil,
                        foundInt! == 1 {
                        isFat = true
                    }
                //case   "grade":
                // case  "is_water":
                //case   "score":
                //case  "positive_points":
                //case  "negative_points":
                default: break
                }
            }
            nutriscore = NutritionalScoreFR.init(energyPoints: energy, saturatedFatPoints: saturatedFatToTotalFatRatio, saturatedFatToTotalFatRatioPoints: saturatedFat, sugarPoints: sugars, sodiumPoints: sodium, fiberPoints: fiber, proteinPoints: proteins, fruitsVegetableNutsPoints: fruitsVegetableNuts, fruitsVegetableNutsEstimatedPoints: nil, isBeverage: isBeverage, isFat: isFat, isCheese: isCheese)
            
        }
        
        init() {
        }

        convenience init(nutritionalDataFR: NutritionalScoreFR) {
            self.init()
            nutriscore = nutritionalDataFR
        }
        
        func encode(to encoder: Encoder) throws {
            
            var container = encoder.container(keyedBy: DetailedKeys.self)
            
            /*
            if let key = DetailedKeys(stringValue: "energy_points") {
                if let validValue = nutriscore?.energy {
                    try container.encodeIfPresent(validValue ? 1 : 0, forKey: key)
                }
            }
            if let key = DetailedKeys(stringValue: "proteins_points") {
                if let validValue = nutriscore?.proteins {
                    try container.encodeIfPresent(validValue ? 1 : 0, forKey: key)
                }
            }
            if let key = DetailedKeys(stringValue: "sodium_points") {
                if let validValue = nutriscore?.sodium {
                    try container.encodeIfPresent(validValue ? 1 : 0, forKey: key)
                }
            }
            if let key = DetailedKeys(stringValue: "sugars_points") {
                if let validValue = nutriscore?.isBeverage {
                    try container.encodeIfPresent(validValue ? 1 : 0, forKey: key)
                }
            }
            if let key = DetailedKeys(stringValue: "fiber_points") {
                if let validValue = nutriscore?.isBeverage {
                    try container.encodeIfPresent(validValue ? 1 : 0, forKey: key)
                }
            }
            if let key = DetailedKeys(stringValue: "saturated_fat_ratio_points") {
                if let validValue = nutriscore?.isFat {
                    try container.encodeIfPresent(validValue ? 1 : 0, forKey: key)
                }
            }
            if let key = DetailedKeys(stringValue: "saturated_fat_points") {
                if let validValue = nutriscore?.isFat {
                    try container.encodeIfPresent(validValue ? 1 : 0, forKey: key)
                }
            }
 */
            if let key = DetailedKeys(stringValue: "is_cheese") {
                if let validValue = nutriscore?.isCheese {
                    try container.encodeIfPresent(validValue ? 1 : 0, forKey: key)
                }
            }

            // The other elements are not written to and always nil
        }

    }
