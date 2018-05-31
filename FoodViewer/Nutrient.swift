//
//  Nutrient.swift
//  FoodViewer
//
//  Created by arnaud on 21/12/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//
//  These are the possible keys for the nutriments that are used in the OFF taxonomies
import Foundation

public enum Nutrient: String, EnumCollection {
    
    case addedSugars = "added-sugars"
    case alcohol = "alcohol"
    case alphaLinolenicAcid = "alpha-linolenic-acid"
    case arachidicAcid = "arachidic-acid"
    case arachidonicAcid = "arachidonic-acid"
    case behenicAcid = "behenic-acid"
    case bicarbonate = "bicarbonate"
    case biotin = "biotin"
    case butyricAcid = "butyric-acid"
    case caffeine = "caffeine"
    case calcium = "calcium"
    case capricAcid = "capric-acid"
    case caproicAcid = "caproic-acid"
    case caprylicAcid = "caprylic-acid"
    case carbohydrates = "carbohydrates"
    // "carbon-footprint_100g"
    case casein = "casein"
    case chloride = "chloride"
    case chromium = "chromium"
    case ceroticAcid = "cerotic-acid"
    case cholesterol = "cholesterol"
    case cocoa = "cocoa"
    case copper = "copper"
    case dihomoGammaLinolenicAcid = "dihomo-gamma-linolenic-acid"
    case docosahexaenoicAcid = "docosahexaenoic-acid"
    case eicosapentaenoicAcid = "eicosapentaenoic-acid"
    case elaidicAcid = "elaidic-acid"
    case energy = "energy"
    case energyFromFat = "energy-from-fat"
    case erucicAcid = "erucic-acid"
    case fat = "fat"
    case fiber = "fiber"
    case fluoride = "fluoride"
    case fructose = "fructose"
    // "fruits-vegetables-nuts_100g
    case gammaLinolenicAcid = "gamma-linolenic-acid"
    case glucose = "glucose"
    case gondoicAcid = "gondoic-acid"
    case iodine = "iodine"
    case iron = "iron"
    case lactose = "lactose"
    case lauricAcid = "lauric-acid"
    case lignocericAcid = "lignoceric-acid"
    case linoleicAcid = "linoleic-acid"
    case magnesium = "magnesium"
    case maltodextrins = "maltodextrins"
    case maltose = "maltose"
    case manganese = "manganese"
    case meadAcid = "mead-acid"
    case melissicAcid = "melissic-acid"
    case molybdenum = "molybdenum"
    case monounsaturatedFat = "monounsaturated-fat"
    case montanicAcid = "montanic-acid"
    case myristicAcid = "myristic-acid"
    case nervonicAcid = "nervonic-acid"
    case nucleotides = "nucleotides"
    case oleicAcid = "oleic-acid"
    case omega3Fat = "omega-3-fat"
    case omega6Fat = "omega-6-fat"
    case omega9Fat = "omega-9-fat"
    case palmiticAcid = "palmitic-acid"
    case pantothenicAcid = "pantothenic-acid"
    case ph = "ph"
    case phosphorus = "phosphorus"
    case polyols = "polyols"
    case polyunsaturatedFat = "polyunsaturated-fat"
    case potassium = "potassium"
    case proteins = "proteins"
    case salt = "salt"
    case saturatedFat = "saturated-fat"
    case selenium = "selenium"
    case serumProteins = "serum-proteins"
    case silica = "silica"
    case sodium = "sodium"
    case sucrose = "sucrose"
    case sugars = "sugars"
    case starch = "starch"
    case stearicAcid = "stearic-acid"
    case taurine = "taurine"
    case transFat = "trans-fat"
    case voleicAcid = "voleic-acid"
    case vitaminA = "vitamin-a"
    case vitaminD = "vitamin-d"
    case vitaminE = "vitamin-e"
    case vitaminK = "vitamin-k"
    case vitaminC = "vitamin-c"
    case vitaminB1 = "vitamin-b1"
    case vitaminB2 = "vitamin-b2"
    case vitaminPP = "vitamin-pp"
    case vitaminB6 = "vitamin-b6"
    case vitaminB9 = "vitamin-b9"
    case vitaminB12 = "vitamin-b12"
    case zinc = "zinc"
    
    case undefined = "undefined"
        
    public var key: String {
        return self.rawValue
    }
    
    static func value(for key: String) -> Nutrient {
        for value in allValues() {
            if "en:" + value.key == key {
                return value
            }
        }
        print("Nutrient: ", key, "not found" )
        return .undefined
    }
    
    func unit(for style:NutritionFactsLabelStyle) -> NutritionFactUnit {
        switch self {
        case .energy:
            switch style.energyUnit {
            case .calories:
                return .Calories
            case .joule:
                return .Joule
            case .kilocalorie:
                return .KiloCalories
            }
        case .ph:
            return .None
        default:
            return .Gram
        }
    }
}

public protocol EnumCollection : Hashable {}

extension EnumCollection {
    
    public static func allValues() -> [Self] {
        typealias S = Self
        
        let retVal = AnySequence { () -> AnyIterator<S> in
            var raw = 0
            return AnyIterator {
                let current = withUnsafePointer(to: &raw) {
                    $0.withMemoryRebound(to: S.self, capacity: 1) { $0.pointee }
                }
                guard current.hashValue == raw else { return nil }
                raw += 1
                return current
            }
        }
        
        return [S](retVal)
    }

}


