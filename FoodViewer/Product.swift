//
//  Product.swift
//  FoodViewer
//
//  Created by arnaud on 30/01/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

class FoodProduct {
    
    // A very flat datastructure has been used for this class
    
    // identification parameters
    var barcode = BarcodeType.Undefined("")
    var name: String? = nil
    var commonName: String? = nil
    var brandsArray: [String]? = nil
    var mainUrlThumb: NSURL? = nil
    var mainUrl: NSURL? = nil
    
    // packaging parameters
    var quantity: String? = nil
    var packagingArray: [String]? = nil
    
    // ingredients parameters
    var ingredients: String? = nil
    var imageIngredientsSmallUrl: NSURL? = nil
    var imageIngredientsUrl: NSURL? = nil
    var allergens: [String]? = nil
    var traces: [String]? = nil
    var additives: [String]? = nil

    // usage parameters
    var servingSize: String? = nil
    
    // content parameters
    var nutritionFacts: [NutritionFactItem]? = nil
    var nutritionScore: [(NutritionItem, NutritionLevelQuantity)]? = nil
    var imageNutritionSmallUrl: NSURL? = nil
    
    // purchase parameters
    var nutritionGrade: NutritionalGradeLevel? = nil
    var purchaseLocation: [String]? = nil //or a set?
    var stores: [String]? = nil //or a set?
    var countries: [String]? = nil //or a set?
    
    // contributor parameters
    var additionDate: NSDate? = nil
    var additionUser: String? = nil
    
    // group parameters
    var categories: [String]? = nil
    
    struct NutritionFactItem {
        var itemName: String? = nil
        var standardValue: String? = nil
        var standardValueUnit: String? = nil
        var servingValue: String? = nil
        var servingValueUnit: String? = nil
        
        func valid() -> Bool {
            if standardValue != nil && !standardValue!.isEmpty {
                return true
            } else {
                return false
            }
        }
    }
    
    enum NutritionalGradeLevel {
        case A
        case B
        case C
        case D
        case E
        case Undefined
        
        mutating func int(value: Int?) {
            if let existingValue = value {
                if existingValue <= -1 {
                    self = .A
                } else if existingValue <= 2 {
                    self = .B
                } else if existingValue <= 10 {
                    self = .C
                } else if existingValue <= 18 {
                    self = .D
                } else if existingValue > 18 {
                    self = .E
                }
            } else {
                self = .Undefined
            }
        }
        
        mutating func string(value: String?) {
            if let existingValue = value {
                if existingValue == "a" {
                    self = .A
                } else if existingValue == "b" {
                    self = .B
                } else if existingValue == "c" {
                    self = .C
                } else if existingValue == "d" {
                    self = .D
                } else if existingValue == "e" {
                    self = .E
                } else {
                    self = .Undefined
                }
            } else {
                self = .Undefined
            }
        }

    }
    
    enum NutritionItem {
        case Fat
        case SaturatedFat
        case Sugar
        case Salt
        case Undefined
    }
        
    enum NutritionLevelQuantity {
        case Low
        case Moderate
        case High
        case Undefined
        
        mutating func string(s:String?) {
            if let newString = s {
                if newString == "high" {
                    self = .High
                } else if newString == "moderate" {
                    self = .Moderate
                } else if newString == "low" {
                    self = .Low
                } else {
                    self = .Undefined
                }
            } else {
                self = .Undefined
            }

        }
    }
    
    enum BarcodeType {
        case EAN13(String)
        case Undefined(String)
        
        mutating func string(s: String?) {
            if let newString = s {
                self = .Undefined(newString)
            }
        }
        
        func asString() -> String {
            switch self {
            case .EAN13(let s):
                return s
            case .Undefined(let s):
                return s
            }
        }
    }
    
    func setTestProduct() {
        //
        // using http://fr-en.openfoodfacts.org/product/3256221510287/vinaigrette-huile-d-olive-13-citron-26-mg-u
        
        barcode = .EAN13("3256221510287")
        
        name = "Vinaigrette huile d'olive 13% & Citron 26% MG"
        commonName = "Vinaigrette à l'huile d'olive et au jus de citron allégée en matières grasses"
        quantity = "50 cl"
        packagingArray = ["Bouteille", "Plastique"]
        categories = ["Groceries", "Sauces", "Salad dressings", "Vinaigrettes", "fr:Vinaigrettes allégées en matières grasses"]
        purchaseLocation = ["Castelnau-le-lez", "France"]
        stores = ["Super U"]
        countries = ["France"]
        ingredients = "Eau, huile d'olive vierge extra 13 %, huile de colza 12 %, vinaigre d'alcool et de vin blanc (contient des sulfites), sel, épaississants : amidon transformé de pomme de terre et gomme xanthane, sucre, moutarde de Dijon (eau, graines de moutarde, vinaigre d'alcool, sel, conservateurs : disulfite de potassium, acidifiant : acide citrique), jus de citron concentré 0,58 %, colorant : lutéine, protéines de lait, arôme" //should take into account the bold items
        allergens = ["Milk", "Mustard", "Sulphur dioxide and sulphites"]
        additives = ["E224 - Potassium metabisulphite", "E330 - Citric acid", "E161b - Lutein", "E415 - Xanthan gum"]
        servingSize = " 10 ml"
        
        let fatNutritionScore = (NutritionItem.Fat, NutritionLevelQuantity.High)
        let saturatedFatNutritionScore = (NutritionItem.SaturatedFat, NutritionLevelQuantity.Moderate)
        let sugarNutritionScore = (NutritionItem.Sugar, NutritionLevelQuantity.Low)
        let saltNutritionScore = (NutritionItem.Salt, NutritionLevelQuantity.High)
        nutritionScore = [fatNutritionScore, saturatedFatNutritionScore, sugarNutritionScore, saltNutritionScore]
        
        var energie = NutritionFactItem()
            energie.itemName = "Energie"
            energie.servingValue = "99.7"
            energie.servingValueUnit = "kJ"
            energie.standardValue = "997"
            energie.standardValueUnit = "kJ"
        
        var fat = NutritionFactItem()
            fat.itemName = "Fat"
            fat.servingValue = "2.5"
            fat.servingValueUnit = "g"
            fat.standardValue = "25"
            fat.standardValueUnit = "g"
        var saturatedFat = NutritionFactItem()
            saturatedFat.itemName = "Saturated Fat"
            saturatedFat.servingValue = "1.9"
            saturatedFat.servingValueUnit = "g"
            saturatedFat.standardValue = "19"
            saturatedFat.standardValueUnit = "g"
        var carbohydrate = NutritionFactItem()
            carbohydrate.itemName = "Carbohydrate"
            carbohydrate.servingValue = "0.34"
            carbohydrate.servingValueUnit = "g"
            carbohydrate.standardValue = "3.4"
            carbohydrate.standardValueUnit = "g"
        var sugars = NutritionFactItem()
            sugars.itemName = "Sugars"
            sugars.servingValue = "1.1"
            sugars.servingValueUnit = "g"
            sugars.standardValue = "11"
            sugars.standardValueUnit = "g"
        var protein = NutritionFactItem()
            protein.itemName = "Protein"
            protein.servingValue = "0.06"
            protein.servingValueUnit = "g"
            protein.standardValue = "0.6"
            protein.standardValueUnit = "g"
        var salt = NutritionFactItem()
            salt.itemName = "Salt"
            salt.servingValue = "0.19"
            salt.servingValueUnit = "g"
            salt.standardValue = "1.9"
            salt.standardValueUnit = "g"

        nutritionFacts = [energie, fat, saturatedFat, carbohydrate, sugars, protein, salt]

        additionDate = NSDate()
        additionUser = "princesseb612"
    }
        
// TBD what about the languages?
    
}
