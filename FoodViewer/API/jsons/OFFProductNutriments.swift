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
        static let Prepared = "_prepared"
    }
    var nutriments: [String:OFFProductNutrimentValues]
    var preparedNutriments: [String:OFFProductNutrimentValues]

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
        var preparedNutrimentsFound: [String:OFFProductNutrimentValues] = [:]
        
        for key in container.allKeys {
            for nutriment in Nutrient.allCases {
                switch key.stringValue {
                case nutriment.rawValue:
                    guard let validValue = container.forceString(key: key) else { break }
                    if nutrimentsFound[nutriment.rawValue] == nil {
                        nutrimentsFound[nutriment.rawValue] = OFFProductNutrimentValues()
                    }
                    nutrimentsFound[nutriment.rawValue]?.base = validValue
                    
                case nutriment.rawValue + Constants.HunderdGram :
                    if nutrimentsFound[nutriment.rawValue] == nil {
                        nutrimentsFound[nutriment.rawValue] = OFFProductNutrimentValues()
                    }
                    nutrimentsFound[nutriment.rawValue]?.per100g = container.forceString(key: key)
                        
                case nutriment.rawValue + Constants.Serving :
                        if nutrimentsFound[nutriment.rawValue] == nil {
                            nutrimentsFound[nutriment.rawValue] = OFFProductNutrimentValues()
                        }
                    nutrimentsFound[nutriment.rawValue]?.serving = container.forceString(key: key)

                case nutriment.rawValue + Constants.Value :
                        if nutrimentsFound[nutriment.rawValue] == nil {
                            nutrimentsFound[nutriment.rawValue] = OFFProductNutrimentValues()
                        }
                    nutrimentsFound[nutriment.rawValue]?.value = container.forceString(key: key)

                case nutriment.rawValue + Constants.Unit :
                        if nutrimentsFound[nutriment.rawValue] == nil {
                            nutrimentsFound[nutriment.rawValue] = OFFProductNutrimentValues()
                        }
                    nutrimentsFound[nutriment.rawValue]?.unit = container.forceString(key: key)

                case nutriment.rawValue + Constants.Label :
                        if nutrimentsFound[nutriment.rawValue] == nil {
                            nutrimentsFound[nutriment.rawValue] = OFFProductNutrimentValues()
                        }
                    nutrimentsFound[nutriment.rawValue]?.label = container.forceString(key: key)

                case nutriment.rawValue + Constants.Prepared + Constants.HunderdGram :
                        if preparedNutrimentsFound[nutriment.rawValue] == nil {
                            preparedNutrimentsFound[nutriment.rawValue] = OFFProductNutrimentValues()
                        }
                    preparedNutrimentsFound[nutriment.rawValue]?.per100g = container.forceString(key: key)

                case nutriment.rawValue + Constants.Prepared + Constants.Serving :
                    if preparedNutrimentsFound[nutriment.rawValue] == nil {
                        preparedNutrimentsFound[nutriment.rawValue] = OFFProductNutrimentValues()
                    }
                    preparedNutrimentsFound[nutriment.rawValue]?.serving = container.forceString(key: key)

                case nutriment.rawValue + Constants.Prepared + Constants.Value :
                    if preparedNutrimentsFound[nutriment.rawValue] == nil {
                        preparedNutrimentsFound[nutriment.rawValue] = OFFProductNutrimentValues()
                    }
                    preparedNutrimentsFound[nutriment.rawValue]?.value = container.forceString(key: key)

                case nutriment.rawValue + Constants.Prepared + Constants.Unit :
                    if preparedNutrimentsFound[nutriment.rawValue] == nil {
                        preparedNutrimentsFound[nutriment.rawValue] = OFFProductNutrimentValues()
                    }
                    preparedNutrimentsFound[nutriment.rawValue]?.unit = container.forceString(key: key)

                case nutriment.rawValue + Constants.Prepared + Constants.Label  :
                    if preparedNutrimentsFound[nutriment.rawValue] == nil {
                        preparedNutrimentsFound[nutriment.rawValue] = OFFProductNutrimentValues()
                    }
                    preparedNutrimentsFound[nutriment.rawValue]?.label = container.forceString(key: key)

                default:
                    break
                }
            }
        }
        nutriments = nutrimentsFound
        preparedNutriments = preparedNutrimentsFound
    }
    
    init() {
        self.nutriments = [:]
        self.preparedNutriments = [:]
    }

    convenience init(nutritionFactsDict: [String: NutritionFactItem],
                     preparedNutritionFactsDict: [String: NutritionFactItem]) {
        self.init()
        for nutritionFact in nutritionFactsDict {
            self.nutriments[nutritionFact.key] = OFFProductNutrimentValues(base: nil,
                                                                  per100g: nutritionFact.value.standard,
                                                                  serving: nutritionFact.value.serving,
                                                                  value: nutritionFact.value.value,
                                                                  label: nil,
                                                                  unit: nutritionFact.value.standardUnit?.short)
        }
        for nutritionFact in preparedNutritionFactsDict {
            self.preparedNutriments[nutritionFact.key] = OFFProductNutrimentValues(base: nil,
                                                                  per100g: nutritionFact.value.standard,
                                                                  serving: nutritionFact.value.serving,
                                                                  value: nutritionFact.value.value,
                                                                  label: nil,
                                                                  unit: nutritionFact.value.standardUnit?.short)
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
        for nutriment in preparedNutriments {
            // per 100 g
            if let key = DetailedKeys(stringValue: nutriment.key + Constants.Prepared + Constants.HunderdGram) {
                try container.encodeIfPresent(nutriment.value.per100g, forKey: key)
            }
            // per serving
            if let key = DetailedKeys(stringValue: nutriment.key + Constants.Prepared + Constants.Serving) {
                try container.encodeIfPresent(nutriment.value.serving, forKey: key)
            }
            // unit
            if let key = DetailedKeys(stringValue: nutriment.key + Constants.Prepared + Constants.Unit) {
                try container.encodeIfPresent(nutriment.value.unit, forKey: key)
            }
            // The other elements are not wriiten to and always nil
        }

    }

}
