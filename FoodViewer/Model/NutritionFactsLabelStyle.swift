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
    case canada // perServing, Cal (energy, fat, saturated, trans, cholesterol, sodium, carbohydrate, fibre, sugars, protein, vitA, vitC, Calcium, Iron)
    case china
    case europe // per 100g, kJ (energy, fat, saturates, carbohydrates, sugars, protein, salt)
    case hongkong
    case india
    case mexico
    case newZealand // perServing, kJ, (energy, protein, fat, saturated fat, carbohydrate, suguars, sodium)
    case unitedStatesOld // perServing, Cal (energy, fat, saturated, trans, cholesterol, sodium, carbohydrate, fibre, sugars, protein, vitA, vitC, Calcium, Iron)
    case unitedStates
    case simple
    
    static var current: NutritionFactsLabelStyle {
        switch Locale.countryCode {
        case "AU":
            return .australia
        case "CA":
            return .canada
        case "CN":
            return .china
        case "HK":
            return .hongkong
        case "IN":
            return .india
        case "MX":
            return .mexico
        case "NZ":
            return .newZealand
        case "US":
            return .unitedStates
        default:
            return .simple
        }
    }
    
    // the reference value used to calculate the nutrient values
    var entryUnit: NutritionEntryUnit {
        switch self {
        case .australia, .canada, .newZealand, .unitedStates, .unitedStatesOld:
            return .perServing
        case .china, .europe, .hongkong, .india, .mexico, .simple:
            return .perStandardUnit
        }
    }
    
    var energyUnit: EnergyUnitUsed {
        switch self {
        case .australia, .china, .europe, .hongkong, .mexico, .newZealand, .simple:
            return .joule
        case .unitedStatesOld, .unitedStates, .canada:
            return .calories
        case .india:
            return .kilocalorie
        }
    }
    
    // The default nutrients can be used to quickly setup a nutrition table
    var mandatoryNutrients: [Nutrient] { // are expressed as OFF keys
        switch self {
        case .simple:
            return [.energy, .proteins, .fat, .saturatedFat, .transFat, .carbohydrates, .sugars, .sodium]
        case .newZealand, .australia:
            return [.energy, .proteins, .fat, .saturatedFat, .carbohydrates, .sugars, .sodium]
        case .canada:
            return [.energy, .fat, .saturatedFat, .transFat, .cholesterol, .sodium, .carbohydrates, .fiber, .sugars, .proteins, .vitaminA, .vitaminC, .calcium, .iron]
        case .china:
            return [.energy, .proteins, .fat, .saturatedFat, .transFat, .carbohydrates, .sugars, .sodium]
        case .europe:
            return [.energy, .fat, .saturatedFat, .carbohydrates, .sugars, .proteins, .salt]
        case .hongkong:
            return [.energy, .proteins, .fat, .saturatedFat, .transFat, .carbohydrates, .sugars, .sodium]
        case .unitedStatesOld:
            return [.energy, .fat, .saturatedFat, .transFat, .cholesterol, .sodium, .carbohydrates, .fiber, .sugars, .proteins, .vitaminA, .vitaminC, .calcium, .iron]
        case .unitedStates:
            return [.energy, .fat, .saturatedFat, .transFat, .cholesterol, .sodium, .carbohydrates, .fiber, .sugars, .addedSugars, .proteins, .vitaminD, .calcium, .iron, .potassium]
        case .india:
            return [.energy, .fat, .carbohydrates, .sugars, .proteins ]
        case .mexico:
            return [.energy, .proteins, .fat, .carbohydrates, .fiber, .sodium]
        }
    }
    
    var keys: Set<Nutrient> {
        switch self {
        case .australia, .newZealand:
            return [.energy, .proteins, .fat, .saturatedFat, .monounsaturatedFat, .polyunsaturatedFat,
                    .transFat, .carbohydrates, .sugars,
                    .addedSugars, .fructose, .glucose, .lactose, .maltose, .maltodextrins, .polyols, .sucrose, .starch,
                    
                    .fiber,  .sodium, .cholesterol, .vitaminA, .vitaminB1, .vitaminB2, .pantothenicAcid,
                    .vitaminB6, .biotin, .vitaminB9, .vitaminB12, .vitaminC, .vitaminD, .vitaminE, .vitaminK, .vitaminPP,
                    
                    .butyricAcid, .caproicAcid, .caprylicAcid, .capricAcid, .lauricAcid, .myristicAcid,
                    .palmiticAcid, .stearicAcid, .arachidicAcid, .behenicAcid, .lignocericAcid, .ceroticAcid,
                    .montanicAcid, .melissicAcid, .omega3Fat, .alphaLinolenicAcid, .eicosapentaenoicAcid,
                    .docosahexaenoicAcid, .omega6Fat, .linoleicAcid, .arachidonicAcid, .gammaLinolenicAcid, .dihomoGammaLinolenicAcid, .omega9Fat, .oleicAcid, .elaidicAcid, .gondoicAcid, .meadAcid, .erucicAcid, .nervonicAcid, .taurine,
                    
                    .bicarbonate,  .chloride, .calcium, .chromium, .copper, .fluoride, .iron, .iodine,
                    .manganese, .magnesium, .molybdenum, .phosphorus, .potassium, .selenium, .silica, .zinc,
                    
                    .caffeine, .casein, .serumProteins, .nucleotides, .alcohol, .ph, .cocoa]
            
        case .canada:
            return [.energy, .proteins, .fat, .saturatedFat, .monounsaturatedFat, .polyunsaturatedFat,
                   .transFat, .carbohydrates, .sugars,
                   .addedSugars, .fructose, .glucose, .lactose, .maltose, .maltodextrins, .polyols, .sucrose, .starch,
                   
                   .fiber,  .sodium, .cholesterol, .vitaminA, .vitaminB1, .vitaminB2, .pantothenicAcid,
                   .vitaminB6, .biotin, .vitaminB9, .vitaminB12, .vitaminC, .vitaminD, .vitaminE, .vitaminK, .vitaminPP,
                   
                   .butyricAcid, .caproicAcid, .caprylicAcid, .capricAcid, .lauricAcid, .myristicAcid,
                   .palmiticAcid, .stearicAcid, .arachidicAcid, .behenicAcid, .lignocericAcid, .ceroticAcid,
                   .montanicAcid, .melissicAcid, .omega3Fat, .alphaLinolenicAcid, .eicosapentaenoicAcid,
                   .docosahexaenoicAcid, .omega6Fat, .linoleicAcid, .arachidonicAcid, .gammaLinolenicAcid, .dihomoGammaLinolenicAcid, .omega9Fat, .oleicAcid, .elaidicAcid, .gondoicAcid, .meadAcid, .erucicAcid, .nervonicAcid, .taurine,
                   
                   .bicarbonate,  .chloride, .calcium, .chromium, .copper, .fluoride, .iron, .iodine,
                   .manganese, .magnesium, .molybdenum, .phosphorus, .potassium, .selenium, .silica, .zinc,
                   
                   .caffeine, .casein, .serumProteins, .nucleotides, .alcohol, .ph, .cocoa]
            
            
        case .china:
            return [.energy, .proteins, .fat, .saturatedFat, .monounsaturatedFat, .polyunsaturatedFat,
                    .transFat, .carbohydrates, .sugars,
                    .addedSugars, .fructose, .glucose, .lactose, .maltose, .maltodextrins, .polyols, .sucrose, .starch,
                    
                    .fiber,  .sodium, .cholesterol, .vitaminA, .vitaminB1, .vitaminB2, .pantothenicAcid,
                    .vitaminB6, .biotin, .vitaminB9, .vitaminB12, .vitaminC, .vitaminD, .vitaminE, .vitaminK, .vitaminPP,
                    
                    .butyricAcid, .caproicAcid, .caprylicAcid, .capricAcid, .lauricAcid, .myristicAcid,
                    .palmiticAcid, .stearicAcid, .arachidicAcid, .behenicAcid, .lignocericAcid, .ceroticAcid,
                    .montanicAcid, .melissicAcid, .omega3Fat, .alphaLinolenicAcid, .eicosapentaenoicAcid,
                    .docosahexaenoicAcid, .omega6Fat, .linoleicAcid, .arachidonicAcid, .gammaLinolenicAcid, .dihomoGammaLinolenicAcid, .omega9Fat, .oleicAcid, .elaidicAcid, .gondoicAcid, .meadAcid, .erucicAcid, .nervonicAcid, .taurine,
                    
                    .bicarbonate,  .chloride, .calcium, .chromium, .copper, .fluoride, .iron, .iodine,
                    .manganese, .magnesium, .molybdenum, .phosphorus, .potassium, .selenium, .silica, .zinc,
                    
                    .caffeine, .casein, .serumProteins, .nucleotides, .alcohol, .ph, .cocoa]
            

        case .europe:
            return [.energy, .proteins, .fat, .saturatedFat, .monounsaturatedFat, .polyunsaturatedFat,
                    .transFat, .carbohydrates, .sugars,
                    .addedSugars, .fructose, .glucose, .lactose, .maltose, .maltodextrins, .polyols, .sucrose, .starch,
                    
                    .fiber,  .sodium, .cholesterol, .vitaminA, .vitaminB1, .vitaminB2, .pantothenicAcid,
                    .vitaminB6, .biotin, .vitaminB9, .vitaminB12, .vitaminC, .vitaminD, .vitaminE, .vitaminK, .vitaminPP,
                    
                    .butyricAcid, .caproicAcid, .caprylicAcid, .capricAcid, .lauricAcid, .myristicAcid,
                    .palmiticAcid, .stearicAcid, .arachidicAcid, .behenicAcid, .lignocericAcid, .ceroticAcid,
                    .montanicAcid, .melissicAcid, .omega3Fat, .alphaLinolenicAcid, .eicosapentaenoicAcid,
                    .docosahexaenoicAcid, .omega6Fat, .linoleicAcid, .arachidonicAcid, .gammaLinolenicAcid, .dihomoGammaLinolenicAcid, .omega9Fat, .oleicAcid, .elaidicAcid, .gondoicAcid, .meadAcid, .erucicAcid, .nervonicAcid, .taurine,
                    
                    .bicarbonate,  .chloride, .calcium, .chromium, .copper, .fluoride, .iron, .iodine,
                    .manganese, .magnesium, .molybdenum, .phosphorus, .potassium, .selenium, .silica, .zinc,
                    
                    .caffeine, .casein, .serumProteins, .nucleotides, .alcohol, .ph, .cocoa]
            
            
        case .hongkong:
            return [.energy, .proteins, .fat, .saturatedFat, .monounsaturatedFat, .polyunsaturatedFat,
                    .transFat, .carbohydrates, .sugars,
                    .addedSugars, .fructose, .glucose, .lactose, .maltose, .maltodextrins, .polyols, .sucrose, .starch,
                    
                    .fiber,  .sodium, .cholesterol, .vitaminA, .vitaminB1, .vitaminB2, .pantothenicAcid,
                    .vitaminB6, .biotin, .vitaminB9, .vitaminB12, .vitaminC, .vitaminD, .vitaminE, .vitaminK, .vitaminPP,
                    
                    .butyricAcid, .caproicAcid, .caprylicAcid, .capricAcid, .lauricAcid, .myristicAcid,
                    .palmiticAcid, .stearicAcid, .arachidicAcid, .behenicAcid, .lignocericAcid, .ceroticAcid,
                    .montanicAcid, .melissicAcid, .omega3Fat, .alphaLinolenicAcid, .eicosapentaenoicAcid,
                    .docosahexaenoicAcid, .omega6Fat, .linoleicAcid, .arachidonicAcid, .gammaLinolenicAcid, .dihomoGammaLinolenicAcid, .omega9Fat, .oleicAcid, .elaidicAcid, .gondoicAcid, .meadAcid, .erucicAcid, .nervonicAcid, .taurine,
                    
                    .bicarbonate,  .chloride, .calcium, .chromium, .copper, .fluoride, .iron, .iodine,
                    .manganese, .magnesium, .molybdenum, .phosphorus, .potassium, .selenium, .silica, .zinc,
                    
                    .caffeine, .casein, .serumProteins, .nucleotides, .alcohol, .ph, .cocoa]
            
            
        case .india:
            return [.energy, .proteins, .fat, .saturatedFat, .monounsaturatedFat, .polyunsaturatedFat,
                    .transFat, .carbohydrates, .sugars,
                    .addedSugars, .fructose, .glucose, .lactose, .maltose, .maltodextrins, .polyols, .sucrose, .starch,
                    
                    .fiber,  .sodium, .cholesterol, .vitaminA, .vitaminB1, .vitaminB2, .pantothenicAcid,
                    .vitaminB6, .biotin, .vitaminB9, .vitaminB12, .vitaminC, .vitaminD, .vitaminE, .vitaminK, .vitaminPP,
                    
                    .butyricAcid, .caproicAcid, .caprylicAcid, .capricAcid, .lauricAcid, .myristicAcid,
                    .palmiticAcid, .stearicAcid, .arachidicAcid, .behenicAcid, .lignocericAcid, .ceroticAcid,
                    .montanicAcid, .melissicAcid, .omega3Fat, .alphaLinolenicAcid, .eicosapentaenoicAcid,
                    .docosahexaenoicAcid, .omega6Fat, .linoleicAcid, .arachidonicAcid, .gammaLinolenicAcid, .dihomoGammaLinolenicAcid, .omega9Fat, .oleicAcid, .elaidicAcid, .gondoicAcid, .meadAcid, .erucicAcid, .nervonicAcid, .taurine,
                    
                    .bicarbonate,  .chloride, .calcium, .chromium, .copper, .fluoride, .iron, .iodine,
                    .manganese, .magnesium, .molybdenum, .phosphorus, .potassium, .selenium, .silica, .zinc,
                    
                    .caffeine, .casein, .serumProteins, .nucleotides, .alcohol, .ph, .cocoa]
            
        case .mexico:
            return [.energy, .proteins, .fat, .saturatedFat, .monounsaturatedFat, .polyunsaturatedFat,
                    .transFat, .carbohydrates, .sugars,
                    .addedSugars, .fructose, .glucose, .lactose, .maltose, .maltodextrins, .polyols, .sucrose, .starch,
                    
                    .fiber,  .sodium, .cholesterol, .vitaminA, .vitaminB1, .vitaminB2, .pantothenicAcid,
                    .vitaminB6, .biotin, .vitaminB9, .vitaminB12, .vitaminC, .vitaminD, .vitaminE, .vitaminK, .vitaminPP,
                    
                    .butyricAcid, .caproicAcid, .caprylicAcid, .capricAcid, .lauricAcid, .myristicAcid,
                    .palmiticAcid, .stearicAcid, .arachidicAcid, .behenicAcid, .lignocericAcid, .ceroticAcid,
                    .montanicAcid, .melissicAcid, .omega3Fat, .alphaLinolenicAcid, .eicosapentaenoicAcid,
                    .docosahexaenoicAcid, .omega6Fat, .linoleicAcid, .arachidonicAcid, .gammaLinolenicAcid, .dihomoGammaLinolenicAcid, .omega9Fat, .oleicAcid, .elaidicAcid, .gondoicAcid, .meadAcid, .erucicAcid, .nervonicAcid, .taurine,
                    
                    .bicarbonate,  .chloride, .calcium, .chromium, .copper, .fluoride, .iron, .iodine,
                    .manganese, .magnesium, .molybdenum, .phosphorus, .potassium, .selenium, .silica, .zinc,
                    
                    .caffeine, .casein, .serumProteins, .nucleotides, .alcohol, .ph, .cocoa]
            
            
        case .unitedStates:
            return [.energy, .proteins, .fat, .saturatedFat, .monounsaturatedFat, .polyunsaturatedFat,
                    .transFat, .carbohydrates, .sugars,
                    .addedSugars, .fructose, .glucose, .lactose, .maltose, .maltodextrins, .polyols, .sucrose, .starch,
                    
                    .fiber,  .sodium, .cholesterol, .vitaminA, .vitaminB1, .vitaminB2, .pantothenicAcid,
                    .vitaminB6, .biotin, .vitaminB9, .vitaminB12, .vitaminC, .vitaminD, .vitaminE, .vitaminK, .vitaminPP,
                    
                    .butyricAcid, .caproicAcid, .caprylicAcid, .capricAcid, .lauricAcid, .myristicAcid,
                    .palmiticAcid, .stearicAcid, .arachidicAcid, .behenicAcid, .lignocericAcid, .ceroticAcid,
                    .montanicAcid, .melissicAcid, .omega3Fat, .alphaLinolenicAcid, .eicosapentaenoicAcid,
                    .docosahexaenoicAcid, .omega6Fat, .linoleicAcid, .arachidonicAcid, .gammaLinolenicAcid, .dihomoGammaLinolenicAcid, .omega9Fat, .oleicAcid, .elaidicAcid, .gondoicAcid, .meadAcid, .erucicAcid, .nervonicAcid, .taurine,
                    
                    .bicarbonate,  .chloride, .calcium, .chromium, .copper, .fluoride, .iron, .iodine,
                    .manganese, .magnesium, .molybdenum, .phosphorus, .potassium, .selenium, .silica, .zinc,
                    
                    .caffeine, .casein, .serumProteins, .nucleotides, .alcohol, .ph, .cocoa]
            
            
        case .unitedStatesOld:
            return [.energy, .proteins, .fat, .saturatedFat, .monounsaturatedFat, .polyunsaturatedFat,
                    .transFat, .carbohydrates, .sugars,
                    .addedSugars, .fructose, .glucose, .lactose, .maltose, .maltodextrins, .polyols, .sucrose, .starch,
                    
                    .fiber,  .sodium, .cholesterol, .vitaminA, .vitaminB1, .vitaminB2, .pantothenicAcid,
                    .vitaminB6, .biotin, .vitaminB9, .vitaminB12, .vitaminC, .vitaminD, .vitaminE, .vitaminK, .vitaminPP,
                    
                    .butyricAcid, .caproicAcid, .caprylicAcid, .capricAcid, .lauricAcid, .myristicAcid,
                    .palmiticAcid, .stearicAcid, .arachidicAcid, .behenicAcid, .lignocericAcid, .ceroticAcid,
                    .montanicAcid, .melissicAcid, .omega3Fat, .alphaLinolenicAcid, .eicosapentaenoicAcid,
                    .docosahexaenoicAcid, .omega6Fat, .linoleicAcid, .arachidonicAcid, .gammaLinolenicAcid, .dihomoGammaLinolenicAcid, .omega9Fat, .oleicAcid, .elaidicAcid, .gondoicAcid, .meadAcid, .erucicAcid, .nervonicAcid, .taurine,
                    
                    .bicarbonate,  .chloride, .calcium, .chromium, .copper, .fluoride, .iron, .iodine,
                    .manganese, .magnesium, .molybdenum, .phosphorus, .potassium, .selenium, .silica, .zinc,
                    
                    .caffeine, .casein, .serumProteins, .nucleotides, .alcohol, .ph, .cocoa]
        case .simple:
            return [.energy, .proteins, .fat, .saturatedFat, .monounsaturatedFat, .polyunsaturatedFat,
             .transFat, .carbohydrates, .sugars,
             .addedSugars, .fructose, .glucose, .lactose, .maltose, .maltodextrins, .polyols, .sucrose, .starch,
             
             .fiber,  .sodium, .cholesterol, .vitaminA, .vitaminB1, .vitaminB2, .pantothenicAcid,
             .vitaminB6, .biotin, .vitaminB9, .vitaminB12, .vitaminC, .vitaminD, .vitaminE, .vitaminK, .vitaminPP,
             
             .butyricAcid, .caproicAcid, .caprylicAcid, .capricAcid, .lauricAcid, .myristicAcid,
             .palmiticAcid, .stearicAcid, .arachidicAcid, .behenicAcid, .lignocericAcid, .ceroticAcid,
             .montanicAcid, .melissicAcid, .omega3Fat, .alphaLinolenicAcid, .eicosapentaenoicAcid,
             .docosahexaenoicAcid, .omega6Fat, .linoleicAcid, .arachidonicAcid, .gammaLinolenicAcid, .dihomoGammaLinolenicAcid, .omega9Fat, .oleicAcid, .elaidicAcid, .gondoicAcid, .meadAcid, .erucicAcid, .nervonicAcid, .taurine,
             
             .bicarbonate,  .chloride, .calcium, .chromium, .copper, .fluoride, .iron, .iodine,
             .manganese, .magnesium, .molybdenum, .phosphorus, .potassium, .selenium, .silica, .zinc,
             
             .caffeine, .casein, .serumProteins, .nucleotides, .alcohol, .ph, .cocoa]
        }
    }
}
