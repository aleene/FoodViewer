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
    var labelArray: [String]? = nil

    // production parameters
    var producer: [String]? = nil
    var ingredientsOrigin: [String]? = nil
    var producerCode: [String]? = nil
    
    // usage parameters
    var servingSize: String? = nil
    
    // content parameters
    var nutritionFacts: [NutritionFactItem] = []
    var nutritionScore: [(NutritionItem, NutritionLevelQuantity)]? = nil
    var imageNutritionSmallUrl: NSURL? = nil
    
    // purchase parameters
    var nutritionGrade: NutritionalGradeLevel? = nil
    var purchaseLocation: [String]? = nil //or a set?
    var stores: [String]? = nil //or a set?
    var countries: [String]? = nil //or a set?
    
    // contributor parameters
    var additionDate: NSDate? = nil
    var creator: String? = nil {
        didSet {
            if let user = creator {
                uniqueContributors.insert(user)
                contributorsArray.append((ContributorTypes.CreatorKey, [user]))
            }
        }
    }
    var state = completionState()

    // group parameters
    var categories: [String]? = nil
    
    // community parameters
    var photographers: [String]? = nil {
        didSet {
            if let users = photographers {
                for user in users {
                    uniqueContributors.insert(user)
                }
                contributorsArray.append((ContributorTypes.PhotographersKey, users))
            }
        }
    }
    
    // community parameters
    var correctors: [String]? = nil {
        didSet {
            if let users = correctors {
                for user in users {
                    uniqueContributors.insert(user)
                }
                contributorsArray.append((ContributorTypes.CorrectorKey, users))
            }
        }
    }

    var editors: [String]? = nil {
        didSet {
            if let users = editors {
                for user in users {
                    uniqueContributors.insert(user)
                }
                contributorsArray.append((ContributorTypes.EditorsKey, users))
            }
        }
    }

    var informers: [String]? = nil {
        didSet {
            if let users = informers {
                for user in users {
                    uniqueContributors.insert(user)
                }
                contributorsArray.append((ContributorTypes.InformersKey, users))
            }
        }
    }

    var checkers: [String]? = nil {
        didSet {
            if let users = checkers {
                for user in users {
                    uniqueContributors.insert(user)
                }
                contributorsArray.append((ContributorTypes.CheckersKey, users))
            }
            
        }
    }

    var uniqueContributors = Set<String>()
    
    var contributorsArray: [(String,[String]?)] = []
    
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
    
    struct ContributorTypes {
        static let CheckersKey = "Checkers"
        static let InformersKey = "Informers"
        static let EditorsKey = "Editors"
        static let PhotographersKey = "Photographers"
        static let CreatorKey = "Creator"
        static let CorrectorKey = "Correctors"
    }

    // completion states parameters
    struct completionState {
        var photosValidatedComplete : Bool = false
        var productNameComplete : Bool = false
        var brandsComplete: Bool = false
        var quantityComplete: Bool = false
        var packagingComplete: Bool = false
        var categoriesComplete: Bool = false
        var nutritionFactsComplete: Bool = false
        var photosUploadedComplete: Bool = false
        var ingredientsComplete: Bool = false
        var expirationDateComplete: Bool = false
        
        func completionPercentage() -> Int {
            return Int(photosValidatedComplete) * 10 +
                Int(productNameComplete) * 10 +
                Int(brandsComplete) * 10 +
                Int(quantityComplete) * 10 +
                Int(packagingComplete) * 10 +
                Int(categoriesComplete) * 10 +
                Int(nutritionFactsComplete) * 10 +
                Int(photosUploadedComplete) * 10 +
                Int(ingredientsComplete) * 10 +
                Int(expirationDateComplete) * 10
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
    
    func clearVariables() {
        // A very flat datastructure has been used for this class
        
        // identification parameters
        barcode = BarcodeType.Undefined("")
        name = nil
        commonName = nil
        brandsArray = nil
        mainUrlThumb = nil
        mainUrl = nil
        
        // packaging parameters
        quantity = nil
        packagingArray = nil
        
        // ingredients parameters
        ingredients = nil
        imageIngredientsSmallUrl = nil
        imageIngredientsUrl = nil
        allergens = nil
        traces = nil
        additives = nil
        labelArray = nil
        
        // usage parameters
        servingSize = nil
        
        // content parameters
        nutritionFacts = []
        nutritionScore = nil
        imageNutritionSmallUrl = nil
        
        // purchase parameters
        nutritionGrade = nil
        purchaseLocation = nil //or a set?
        stores = nil //or a set?
        countries = nil //or a set?
        
        // contributor parameters
        additionDate = nil
        creator = nil
        state = completionState()
        
        // group parameters
        categories = nil
        
        // community parameters
        photographers = nil
        editors = nil
        informers = nil
        checkers = nil
        uniqueContributors = []
        contributorsArray = []

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
        creator = "princesseb612"
    }
        
// TBD what about the languages?
    
}
