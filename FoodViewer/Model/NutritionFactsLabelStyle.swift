//
//  NutritionFactsLabelStyle.swift
//  FoodViewer
//
//  Created by arnaud on 15/03/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation

enum NutritionFactsLabelStyle {
    
    case australia // perServing, kJ, (energy, protein, fat, saturated fat, carbohydrate, suguars, sodium)
    case northAmerica // perServing, Cal (energy, fat, saturated, trans, cholesterol, sodium, carbohydrate, fibre, sugars, protein, vitA, vitC, Calcium, Iron)
    case china
    case europe // per 100g, kJ (energy, fat, saturates, carbohydrates, sugars, protein, salt)
    case india
    case japan
    case mexico
    case thailand
    case unitedStates
    case world

//
// MARK: - Static functions and variables
//
    
    static func countries(for style: NutritionFactsLabelStyle) -> Set<String> {
        switch style {
        case .australia:
            return ["en:australia", "en:new-zealand"]
        case .northAmerica:
            return ["en:canada", "en:united-states", "en:united-states-of-america"]
        case .unitedStates:
            return ["en:united-states", "en:united-states-of-america"]
        case .china:
            return ["en:china", "en:hong-kong"]
        case .europe:
            return ["en:austria", "en:belgium", "en:bulgaria", "en:cyprus", "en:denmark", "en:estonia", "en:european-union", "en:finland", "en:france", "en:germany", "en:greece", "en:hungary", "en:iceland", "en:ireland", "en:italy", "en:latvia", "en:liechtenstein", "en:lithuania", "en:luxembourg", "en:malta", "en:monaco", "en:netherlands", "en:norway", "en:poland", "en:portugal", "en:republic-of-ireland", "en:romania", "en:san-marino", "en:scotland", "en:slovakia", "en:slovenia", "en:spain", "en:sweden", "en:switzerland", "en:united-kingdom"]
        case .india:
            return ["en:india"]
        case .japan:
            return ["en:japan"]
        case .mexico:
            return ["en:mexico"]
        case .thailand:
            return ["en:thailand"]
        case .world:
            return []
        }
    }
    static var allStyles: [NutritionFactsLabelStyle] {
        return [.australia, .unitedStates, .northAmerica, .china, .europe, .india, .mexico, .thailand, .world]
    }
    
    // The default nutrients can be used to quickly setup a nutrition table
    var mandatoryNutrients: Set<Nutrient> { // are expressed as OFF keys
        switch self {
        case .world, .china:
            return [.energy, .proteins, .fat, .saturatedFat, .transFat, .carbohydrates, .sugars, .sodium]
        case .europe:
            return [.energy, .energyKcal, .fat, .saturatedFat, .carbohydrates, .sugars, .proteins, .salt]
        case .australia:
            return [.energy, .proteins, .fat, .saturatedFat, .carbohydrates, .sugars, .sodium]
        case .india:
            return [.energy, .fat, .carbohydrates, .sugars, .proteins]
        case .japan:
            return [.energy, .proteins, .fat, .carbohydrates, .sodium]
        case .mexico:
            return [.energy, .proteins, .fat, .carbohydrates, .fiber, .sodium]
        case .northAmerica:
            return [.energy, .fat, .saturatedFat, .transFat, .cholesterol, .sodium, .carbohydrates, .fiber, .sugars, .proteins, .vitaminA, .vitaminC, .calcium, .iron]
        // This sets the new US style nutrition table
        case .unitedStates:
            return [.energy, .fat, .saturatedFat, .transFat, .cholesterol, .sodium, .carbohydrates, .fiber, .sugars,
                    .addedSugars, .proteins, .vitaminD, .calcium, .iron, .potassium]
        case .thailand:
            return [.energy, .fat, .saturatedFat, .transFat, .cholesterol, .proteins, .carbohydrates, .fiber, .sugars, .sodium, .vitaminA, .vitaminB1, .vitaminB2, .calcium, .iron, .vitaminE, .iodine]
        }
    }
    
    // This function analyses a set of nutrients and returns the possible styles that can be supported
    static func styles(for nutrients: Set<Nutrient>) -> Set<NutritionFactsLabelStyle> {
        var styles: Set<NutritionFactsLabelStyle> = []
        if !nutrients.isEmpty {
            for style in self.allStyles {
                if style.mandatoryNutrients.isSubset(of: nutrients) {
                    styles.insert(style)
                }
            }
        }
        return styles
    }
    
    // This function analyses a set of nutrients and returns the styles that fit all available nutrients
    static func optimumStyle(for nutrients: Set<Nutrient>) -> Set<NutritionFactsLabelStyle> {
        var numberOfNutrientsFitted = 0
        var bestStyles: Set<NutritionFactsLabelStyle> = []

        if !nutrients.isEmpty {
            for style in self.allStyles {
                let mandatory = style.mandatoryNutrients
                if mandatory.isSubset(of: nutrients) {
                    if mandatory.count > numberOfNutrientsFitted {
                        numberOfNutrientsFitted = mandatory.count
                    }
                }
            }
            for style in self.allStyles {
                let mandatory = style.mandatoryNutrients
                if mandatory.isSubset(of: nutrients) {
                    if mandatory.count == numberOfNutrientsFitted {
                        bestStyles.insert(style)
                    }
                }
            }

        }
        return bestStyles
    }

    static func styles(for countries: Set<String>) -> Set<NutritionFactsLabelStyle> {
        var styles: Set<NutritionFactsLabelStyle> = []
        var countriesToEvaluate = countries
        for style in self.allStyles {
            let styleCountries = self.countries(for: style)
            let overlap = countriesToEvaluate.intersection(styleCountries)
            if !overlap.isEmpty {
                styles.insert(style)
                countriesToEvaluate.subtract(overlap)
            }
        }
        // If there are still countries left, they are unspecified countries with a .world set of nutrition facts
        if !countriesToEvaluate.isEmpty {
            styles.insert(.world)
        }
        return styles
    }

    static var current: NutritionFactsLabelStyle {
        switch Locale.countryCode {
        case "AU", "NZ":
            return .australia
        case "CA":
            return .northAmerica
        case "CN", "HK":
            return .china
        case "FR", "DE", "NL":
            return .europe
        case "IN":
            return .india
        case "JP":
            return .japan
        case "MX":
            return .mexico
        case "TH":
            return .thailand
        case "US":
            return .unitedStates
        default:
            return .world
        }
    }

    init() {
        self = .current
    }
    
    var description: String {
        switch self {
        case .australia:
            return "Australian/NewZealand"
        case .northAmerica:
            return "Canadian/United States (Old)"
        case .unitedStates:
            return "United States (New)"
        case .china:
            return "China/Hong Kong"
        case .europe:
            return "Europe"
        case .india:
            return "India"
        case .japan:
            return "Japan"
        case .mexico:
            return "Mexico"
        case .thailand:
            return "Thailand"
        case .world:
            return "World"
        }
    }
    // the reference value used to calculate the nutrient values
    var entryUnit: NutritionEntryUnit {
        switch self {
        case .australia, .northAmerica, .unitedStates, .thailand:
            return .perServing
        case .china, .europe, .india, .japan, .mexico, .world:
            return .perStandardUnit
        }
    }
    
    var energyUnit: EnergyUnitUsed {
        switch self {
        case .australia, .china, .europe, .mexico, .world:
            return .joule
        case .northAmerica, .unitedStates:
            return .calories
        case .india, .japan, .thailand:
            return .kilocalorie
        }
    }
    
    var saltUnit: NatriumChloride {
        switch self {
        case .europe:
            return .salt
        default:
            return .sodium
        }
    }
    
    var keys: [Nutrient] {
        switch self {
        // Salt, Protein before Salt
        case .europe:
            return [.energy, .energyKcal, .fat, .saturatedFat, .monounsaturatedFat, .polyunsaturatedFat,
                    .transFat, .carbohydrates, .sugars,
                    .addedSugars, .fructose, .glucose, .lactose, .maltose, .maltodextrins, .polyols, .sucrose, .starch,
                    
                    .fiber, .proteins, .salt, .sodium, .fruitsVegetablesNuts, .fruitsVegetablesNutsEstimate,
                    
                    .cholesterol, .vitaminA, .vitaminB1, .vitaminB2, .pantothenicAcid,
                    .vitaminB6, .biotin, .vitaminB9, .vitaminB12, .vitaminC, .vitaminD, .vitaminE, .vitaminK, .vitaminPP,
                    
                    .butyricAcid, .caproicAcid, .caprylicAcid, .capricAcid, .lauricAcid, .myristicAcid,
                    .palmiticAcid, .stearicAcid, .arachidicAcid, .behenicAcid, .lignocericAcid, .ceroticAcid,
                    .montanicAcid, .melissicAcid, .omega3Fat, .alphaLinolenicAcid, .eicosapentaenoicAcid,
                    .docosahexaenoicAcid, .omega6Fat, .linoleicAcid, .arachidonicAcid, .gammaLinolenicAcid, .dihomoGammaLinolenicAcid,
                    .omega9Fat, .oleicAcid, .elaidicAcid, .gondoicAcid, .meadAcid, .erucicAcid, .nervonicAcid, .taurine,
                    
                    .bicarbonate,  .chloride, .calcium, .chromium, .copper, .fluoride, .iron, .iodine,
                    .manganese, .magnesium, .molybdenum, .phosphorus, .potassium, .selenium, .silica, .zinc,
                    
                    .caffeine, .casein, .serumProteins, .nucleotides, .alcohol, .ph, .cocoa]
            
        // Protein on position 2, uses Sodium
        case .australia, .china, .india, .japan, .mexico, .northAmerica, .unitedStates, .world:
            return [.energy, .proteins, .fat, .saturatedFat, .monounsaturatedFat, .polyunsaturatedFat,
                    .transFat, .carbohydrates, .sugars,
                    .addedSugars, .fructose, .glucose, .lactose, .maltose, .maltodextrins, .polyols, .sucrose, .starch,
                    
                    .fiber,  .sodium, .fruitsVegetablesNuts, .fruitsVegetablesNutsEstimate,
                    .cholesterol, .vitaminA, .vitaminB1, .vitaminB2, .pantothenicAcid,
                    .vitaminB6, .biotin, .vitaminB9, .vitaminB12, .vitaminC, .vitaminD, .vitaminE, .vitaminK, .vitaminPP,
                    
                    .butyricAcid, .caproicAcid, .caprylicAcid, .capricAcid, .lauricAcid, .myristicAcid,
                    .palmiticAcid, .stearicAcid, .arachidicAcid, .behenicAcid, .lignocericAcid, .ceroticAcid,
                    .montanicAcid, .melissicAcid, .omega3Fat, .alphaLinolenicAcid, .eicosapentaenoicAcid,
                    .docosahexaenoicAcid, .omega6Fat, .linoleicAcid, .arachidonicAcid, .gammaLinolenicAcid, .dihomoGammaLinolenicAcid,
                    .omega9Fat, .oleicAcid, .elaidicAcid, .gondoicAcid, .meadAcid, .erucicAcid, .nervonicAcid, .taurine,
                    
                    .bicarbonate,  .chloride, .calcium, .chromium, .copper, .fluoride, .iron, .iodine,
                    .manganese, .magnesium, .molybdenum, .phosphorus, .potassium, .selenium, .silica, .zinc,
                    
                    .caffeine, .casein, .serumProteins, .nucleotides, .alcohol, .ph, .cocoa]
        case .thailand:
            return [.energy, .fat, .saturatedFat, .monounsaturatedFat, .polyunsaturatedFat,
                     .transFat, .carbohydrates,
                     .cholesterol, .proteins,
                    .sugars, .addedSugars, .fructose, .glucose, .lactose, .maltose, .maltodextrins,
                    .polyols, .sucrose, .starch,
                    .fiber, .sodium, .fruitsVegetablesNuts, .fruitsVegetablesNutsEstimate,
                    .vitaminA, .vitaminB1, .vitaminB2, .pantothenicAcid,
                    .vitaminB6, .biotin, .vitaminB9, .vitaminB12, .vitaminC, .vitaminD, .vitaminE, .vitaminK, .vitaminPP,
                    
                    .butyricAcid, .caproicAcid, .caprylicAcid, .capricAcid, .lauricAcid, .myristicAcid,
                    .palmiticAcid, .stearicAcid, .arachidicAcid, .behenicAcid, .lignocericAcid, .ceroticAcid,
                    .montanicAcid, .melissicAcid, .omega3Fat, .alphaLinolenicAcid, .eicosapentaenoicAcid,
                    .docosahexaenoicAcid, .omega6Fat, .linoleicAcid, .arachidonicAcid, .gammaLinolenicAcid, .dihomoGammaLinolenicAcid,
                    .omega9Fat, .oleicAcid, .elaidicAcid, .gondoicAcid, .meadAcid, .erucicAcid, .nervonicAcid, .taurine,
                    
                    .bicarbonate,  .chloride, .calcium, .chromium, .copper, .fluoride, .iron, .iodine,
                    .manganese, .magnesium, .molybdenum, .phosphorus, .potassium, .selenium, .silica, .zinc,
                    
                    .caffeine, .casein, .serumProteins, .nucleotides, .alcohol, .ph, .cocoa]
        }
    }
}
