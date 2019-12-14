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
    private let keys = ["energy", "proteins", "casein", "serum-proteins", "nucleotides", "carbohydrates", "sugars",
        "sucrose", "glucose", "fructose", "lactose", "maltose", "maltodextrins", "starch", "polyols", "fat", "saturated-fat", "butyric-acid", "caproic-acid", "caprylic-acid", "capric-acid", "lauric-acid", "myristic-acid","palmitic-acid", "stearic-acid","arachidic-acid","behenic-acid","lignoceric-acid","cerotic-acid","montanic-acid","melissic-acid", "monounsaturated-fat","polyunsaturated-fat","omega-3-fat","alpha-linolenic-acid","eicosapentaenoic-acid", "docosahexaenoic-acid", "omega-6-fat","linoleic-acid", "arachidonic-acid", "gamma-linolenic-acid", "dihomo-gamma-linolenic-acid", "omega-9-fat","oleic-acid","elaidic-acid","gondoic-acid","mead-acid","erucic-acid","nervonic-acid","trans-fat","cholesterol","fiber","sodium","alcohol","vitamin-a","vitamin-d","vitamin-e","vitamin-k", "vitamin-c","vitamin-b1","vitamin-b2","vitamin-pp","vitamin-b6","vitamin-b9","vitamin-b12","biotin","pantothenic-acid","silica","bicarbonate","potassium","chloride","calcium","phosphorus","iron","magnesium","zinc","copper","manganese","fluoride","selenium","chromium","molybdenum","iodine","caffeine","taurine","carbon-footprint_100g","ph_100g","cocoa","fruits-vegetables-nuts_100g","fruits_vegetables_nuts_estimate_100g","nutrition-score-fr_100g","nutrition-score-uk_100g", "nutrition_score_debug"]
    
    let nutriments: [String:OFFProductNutrimentValues]

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
            for nutriment in keys {
                var base: String? = nil
                if key.stringValue == nutriment {
                    do {
                        let name = try container.decode(String.self, forKey: key)
                        base = name
                    } catch {
                        let name = try container.decode(Float.self, forKey: key)
                        base = "\(name)"
                    }
                }
                var per100g: String? = nil
                if key.stringValue == nutriment + "_100g" {
                    do {
                        let name = try container.decode(String.self, forKey: key)
                        per100g = name
                    } catch {
                        let name = try container.decode(Float.self, forKey: key)
                        per100g = "\(name)"
                    }
                }
                var serving: String? = nil
                if key.stringValue == nutriment + "_serving" {
                    do {
                        let name = try container.decode(String.self, forKey: key)
                        serving = name
                    } catch {
                        let name = try container.decode(Float.self, forKey: key)
                        serving = "\(name)"
                    }
                }
                var value: String? = nil
                if key.stringValue == nutriment + "_value" {
                    do {
                        let name = try container.decode(String.self, forKey: key)
                        value = name
                    } catch {
                        let name = try container.decode(Float.self, forKey: key)
                        value = "\(name)"
                    }
                }
                var unit: String? = nil
                if key.stringValue == nutriment + "_unit" {
                    do {
                        let name = try container.decode(String.self, forKey: key)
                        unit = name
                    }
                }
                var label: String? = nil
                if key.stringValue == nutriment + "_label" {
                    do {
                        let name = try container.decode(String.self, forKey: key)
                        label = name
                    }
                }
                let values = OFFProductNutrimentValues(base: base, per100g: per100g, serving: serving, value: value, label: label, unit: unit)
                if !values.isEmpty {
                    nutrimentsFound[nutriment] = values
                }
            }
        }
        nutriments = nutrimentsFound
    }
    
    func encode(to encoder: Encoder) throws {
        
    }

}
    /*
 
    enum Unit: String, Codable {
        case kcal
        case g
        case mg
    }
    */


