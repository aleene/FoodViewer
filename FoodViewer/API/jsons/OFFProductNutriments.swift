//
//  OFFProductNutriments.swift
//  FoodViewer
//
//  Created by arnaud on 09/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation

class OFFProductNutriments: Codable {
    
    // These keys are taken from https://en.wiki.openfoodfacts.org/API
    // these keys are sorted by popularity
    // firs the stand eu keys, than the standard us keys
    /*
    private let keys = ["energy", "energy-kcal", "energy-from-fat", "carbohydrates", "fat", "saturated-fat", "sugars", "proteins", "fiber", "salt",
                        "trans-fat","sodium", "cholesterol", "vitamin-a","vitamin-d",
                        "alcohol", "monounsaturated-fat","polyunsaturated-fat",
                        "ph_100g","cocoa","fruits-vegetables-nuts","fruits-vegetables-nuts-estimate",
                        "vitamin-e","vitamin-k", "vitamin-c","vitamin-b1","vitamin-b2","vitamin-pp",
                        "nutrition-score-fr","nutrition-score-uk", "nutrition_score_debug",
                        "vitamin-b6","vitamin-b9","vitamin-b12","biotin","pantothenic-acid",
                        "casein", "serum-proteins", "nucleotides",
        "sucrose", "glucose", "fructose", "lactose", "maltose", "maltodextrins", "starch", "polyols",
        "butyric-acid", "caproic-acid", "caprylic-acid", "capric-acid", "lauric-acid", "myristic-acid",
        "palmitic-acid", "stearic-acid","arachidic-acid","behenic-acid","lignoceric-acid","cerotic-acid",
        "montanic-acid","melissic-acid", "omega-3-fat","alpha-linolenic-acid","eicosapentaenoic-acid",
        "docosahexaenoic-acid", "omega-6-fat","linoleic-acid", "arachidonic-acid", "gamma-linolenic-acid", "dihomo-gamma-linolenic-acid", "omega-9-fat","oleic-acid","elaidic-acid","gondoic-acid","mead-acid","erucic-acid", "nervonic-acid","silica","bicarbonate","potassium","chloride","calcium","phosphorus","iron",
        "magnesium","zinc","copper","manganese","fluoride","selenium","chromium","molybdenum","iodine",
        "caffeine","taurine","carbon-footprint"]
 */
    
    private struct Constants {
        static let HunderdGram = "_100g"
        static let Serving = "_serving"
        static let Value = "_value"
        static let Unit = "_unit"
        static let Label = "_label"
    }
    var nutriments: [String:OFFProductNutrimentValues]

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
        var nutrimentsFound: [String:OFFProductNutrimentValues] = [:]
        for key in container.allKeys {
            for nutriment in Nutrient.allCases {
                if key.stringValue == nutriment.rawValue {
                    do {
                        let name = try container.decode(String.self, forKey: key)
                        if nutrimentsFound[nutriment.rawValue] == nil {
                            nutrimentsFound[nutriment.rawValue] = OFFProductNutrimentValues()
                        }
                        nutrimentsFound[nutriment.rawValue]?.base = name
                    } catch {
                        do {
                            if nutrimentsFound[nutriment.rawValue] == nil {
                                nutrimentsFound[nutriment.rawValue] = OFFProductNutrimentValues()
                            }
                            let name = try container.decode(Float.self, forKey: key)
                            nutrimentsFound[nutriment.rawValue]?.base = "\(name)"
                        } catch {
                            do {
                                if nutrimentsFound[nutriment.rawValue] == nil {
                                    nutrimentsFound[nutriment.rawValue] = OFFProductNutrimentValues()
                                }
                                let name = try container.decode(Int.self, forKey: key)
                                nutrimentsFound[nutriment.rawValue]?.base = "\(name)"
                            } catch {
                                print("OFFProductNutriments: \(nutriment.rawValue) not convertable")
                            }
                        }
                    }
                    break
                } else if key.stringValue == nutriment.rawValue + Constants.HunderdGram {
                    do {
                        let name = try container.decode(String.self, forKey: key)
                        if nutrimentsFound[nutriment.rawValue] == nil {
                            nutrimentsFound[nutriment.rawValue] = OFFProductNutrimentValues()
                        }
                        nutrimentsFound[nutriment.rawValue]?.per100g = name
                    } catch {
                        let name = try container.decode(Float.self, forKey: key)
                        if nutrimentsFound[nutriment.rawValue] == nil {
                            nutrimentsFound[nutriment.rawValue] = OFFProductNutrimentValues()
                        }
                        nutrimentsFound[nutriment.rawValue]?.per100g = "\(name)"
                    }
                    break
                } else if key.stringValue == nutriment.rawValue + Constants.Serving {
                    do {
                        let name = try container.decode(String.self, forKey: key)
                        if nutrimentsFound[nutriment.rawValue] == nil {
                            nutrimentsFound[nutriment.rawValue] = OFFProductNutrimentValues()
                        }
                        nutrimentsFound[nutriment.rawValue]?.serving = name
                    } catch {
                        let name = try container.decode(Float.self, forKey: key)
                        if nutrimentsFound[nutriment.rawValue] == nil {
                            nutrimentsFound[nutriment.rawValue] = OFFProductNutrimentValues()
                        }
                        nutrimentsFound[nutriment.rawValue]?.serving = "\(name)"
                    }
                    break
                } else if key.stringValue == nutriment.rawValue + Constants.Value {
                    do {
                        let name = try container.decode(String.self, forKey: key)
                        if nutrimentsFound[nutriment.rawValue] == nil {
                            nutrimentsFound[nutriment.rawValue] = OFFProductNutrimentValues()
                        }
                        nutrimentsFound[nutriment.rawValue]?.value = name
                    } catch {
                        let name = try container.decode(Float.self, forKey: key)
                        if nutrimentsFound[nutriment.rawValue] == nil {
                            nutrimentsFound[nutriment.rawValue] = OFFProductNutrimentValues()
                        }
                        nutrimentsFound[nutriment.rawValue]?.value = "\(name)"
                    }
                    break
                } else if key.stringValue == nutriment.rawValue + Constants.Unit {
                    do {
                        if nutrimentsFound[nutriment.rawValue] == nil {
                            nutrimentsFound[nutriment.rawValue] = OFFProductNutrimentValues()
                        }
                        nutrimentsFound[nutriment.rawValue]?.unit = try container.decode(String.self, forKey: key)
                    } catch {
                        nutrimentsFound[nutriment.rawValue]?.unit = ""
                    }
                } else if key.stringValue == nutriment.rawValue + Constants.Label  {
                    do {
                        if nutrimentsFound[nutriment.rawValue] == nil {
                            nutrimentsFound[nutriment.rawValue] = OFFProductNutrimentValues()
                        }
                        nutrimentsFound[nutriment.rawValue]?.label = try container.decode(String.self, forKey: key)
                    } catch {
                        nutrimentsFound[nutriment.rawValue]?.label = ""
                    }
                    break
                }
            }
        }
        
        nutriments = nutrimentsFound
    }
    
    init() {
        self.nutriments = [:]
    }

    convenience init(nutritionFactsDict: [String:NutritionFactItem]) {
        self.init()
        for nutritionFact in nutritionFactsDict {
            self.nutriments[nutritionFact.key] = OFFProductNutrimentValues(base: nil,
                                                                  per100g: nutritionFact.value.standard,
                                                                  serving: nutritionFact.value.serving,
                                                                  value: nutritionFact.value.value,
                                                                  label: nil,
                                                                  unit: nutritionFact.value.standardUnit?.short())
        }
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: DetailedKeys.self)
        
        for nutriment in nutriments {
            // per 100 g
            if let key = DetailedKeys(stringValue: nutriment.key + Constants.HunderdGram) {
                try container.encodeIfPresent(nutriment.value.per100g, forKey: key)
            }
            // per serving
            if let key = DetailedKeys(stringValue: nutriment.key + Constants.Serving) {
                try container.encodeIfPresent(nutriment.value.serving, forKey: key)
            }
            // unit
            if let key = DetailedKeys(stringValue: nutriment.key + Constants.Unit) {
                try container.encodeIfPresent(nutriment.value.unit, forKey: key)
            }
            // The other elements are not wriiten to and always nil
        }
    }

}
