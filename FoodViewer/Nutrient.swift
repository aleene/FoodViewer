//
//  Nutrient.swift
//  FoodViewer
//
//  Created by arnaud on 21/12/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//
//  These are the possible keys for the nutriments that are used in the OFF taxonomies
import Foundation

public enum Nutrient: String, CaseIterable {
    
    case addedSugars = "added-sugars"
    case alcohol = "alcohol"
    case alphaLinolenicAcid = "alpha-linolenic-acid"
    case arachidicAcid = "arachidic-acid"
    case arachidonicAcid = "arachidonic-acid"
    case ausUnits = "aus-units"
    case behenicAcid = "behenic-acid"
    case betaCarotene = "beta-carotene"
    case bicarbonate = "bicarbonate"
    case biotin = "biotin"
    case butyricAcid = "butyric-acid"
    case caffeine = "caffeine"
    case calcium = "calcium"
    case capricAcid = "capric-acid"
    case caproicAcid = "caproic-acid"
    case caprylicAcid = "caprylic-acid"
    case carbohydrates = "carbohydrates"
    case carnitine = "carnitine"
    case carbonFootprint = "carbon-footprint"
    // "carbon-footprint_100g"
    case casein = "casein"
    case chloride = "chloride"
    case chlorophyl = "chlorophyl"
    case choline = "choline"
    case chromium = "chromium"
    case ceroticAcid = "cerotic-acid"
    case cholesterol = "cholesterol"
    case cocoa = "cocoa"
    case collagenMeatProteinRatio = "collagen-meat-protein-ratio"
    case copper = "copper"
    case dihomoGammaLinolenicAcid = "dihomo-gamma-linolenic-acid"
    case docosahexaenoicAcid = "docosahexaenoic-acid"
    case eicosapentaenoicAcid = "eicosapentaenoic-acid"
    case elaidicAcid = "elaidic-acid"
    case energy = "energy"
    case energyKcal = "energy-kcal"
    case energyFromFat = "energy-from-fat"
    case erucicAcid = "erucic-acid"
    case fat = "fat"
    case fiber = "fiber"
    case fluoride = "fluoride"
    case fructose = "fructose"
    case fruitsVegetablesNuts = "fruits-vegetables-nuts"
    case fruitsVegetablesNutsEstimate = "fruits-vegetables-nuts-estimate"
    case gammaLinolenicAcid = "gamma-linolenic-acid"
    case glucose = "glucose"
    case gondoicAcid = "gondoic-acid"
    case hydrogencarbonates = "hydrogencarbonates"
    case ieUnits = "ie-units"
    case inositol = "inositol"
    case insolubleFiber = "insoluble-fiber"
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
    case mineral = "mineral"
    case molybdenum = "molybdenum"
    case monounsaturatedFat = "monounsaturated-fat"
    case montanicAcid = "montanic-acid"
    case myristicAcid = "myristic-acid"
    case nervonicAcid = "nervonic-acid"
    case nucleotides = "nucleotides"
    case numberOfMinerals = "#minerals"
    case numberOfVitamins = "#vitamins"
    case oleicAcid = "oleic-acid"
    case omega3Fat = "omega-3-fat"
    case omega6Fat = "omega-6-fat"
    case omega9Fat = "omega-9-fat"
    case palmiticAcid = "palmitic-acid"
    case pantothenicAcid = "pantothenic-acid"
    case ph = "ph"
    case phosphorus = "phosphorus"
    case phylloquinone = "phylloquinone"
    case polyols = "polyols"
    case polyunsaturatedFat = "polyunsaturated-fat"
    case potassium = "potassium"
    case proteins = "proteins"
    case salt = "salt"
    case saltEquivalent = "salt-equivalent"
    case saturatedFat = "saturated-fat"
    case saturatedFatRatio = "fr-sat-fat-for-fats"
    case saUnits = "sa-units"
    case selenium = "selenium"
    case serumProteins = "serum-proteins"
    case silica = "silica"
    case sodium = "sodium"
    case sucrose = "sucrose"
    case sulfates = "sulfates"
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
    case vitamins = "vitamins"
    case waterHardness = "water-hardness"
    case zinc = "zinc"
    
    case undefined = "undefined"
        
    public var key: String {
        return self.rawValue
    }
    
    static func value(for key: String) -> Nutrient {
        for value in Nutrient.allCases {
            if "en:" + value.key == key {
                return value
            }
        }
        print("Nutrient: ", key, "not found, it must be added to the enum" )
        return .undefined
    }
    
    func unit(for style:NutritionFactsLabelStyle) -> NutritionFactUnit {
        switch self {
        case .energy, .energyKcal, .energyFromFat:
            switch style.energyUnit {
            case .calories:
                return .calories
            case .joule:
                return .joule
            case .kilocalorie:
                return .kiloCalories
            }
        case .ph, .ausUnits, .numberOfMinerals, .numberOfVitamins, .saUnits, .ieUnits:
            return .none
        default:
            return .gram
        }
    }
}
