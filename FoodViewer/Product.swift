//
//  Product.swift
//  FoodViewer
//
//  Created by arnaud on 30/01/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

class FoodProduct {
    
    // Primary variables
    
    // identification parameters
    var barcode: BarcodeType
    var name: String?
    var commonName: String?
    var brandsArray: [String]?
    var mainUrlThumb: NSURL?
    var mainUrl: NSURL?
    
    // packaging parameters
    var quantity: String?
    var packagingArray: [String]?
    
    // ingredients parameters
    var ingredients: String?
    var imageIngredientsSmallUrl: NSURL?
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
    var imageNutritionSmallUrl: NSURL?
    var nutritionFactsImageUrl: NSURL?
    
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
                if !productContributors.contains(user) {
                    productContributors.add(user)
                }
                productContributors.contributors[productContributors.indexOf(user)!].role.isCreator = true
                contributorsArray.append((ContributorTypes.CreatorKey, [user]))
            }
        }
    }
    var state = CompletionState()
    var primaryLanguage: String? = nil

    // group parameters
    var categories: [String]? = nil
    
    // community parameters
    var photographers: [String]? = nil {
        didSet {
            if let users = photographers {
                for user in users {
                    if !productContributors.contains(user) {
                        productContributors.add(user)
                    }
                    productContributors.contributors[productContributors.indexOf(user)!].role.isPhotographer = true
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
                    if !productContributors.contains(user) {
                        productContributors.add(user)
                    }
                    productContributors.contributors[productContributors.indexOf(user)!].role.isCorrector = true
                }
                contributorsArray.append((ContributorTypes.PhotographersKey, users))
            }
        }
    }

    
    var editors: [String]? = nil {
        didSet {
            if let users = editors {
                for user in users {
                    if !productContributors.contains(user) {
                        productContributors.add(user)
                    }
                    productContributors.contributors[productContributors.indexOf(user)!].role.isEditor = true
                }
                contributorsArray.append((ContributorTypes.EditorsKey, users))
            }
        }
    }

    var informers: [String]? = nil {
        didSet {
            if let users = informers {
                for user in users {
                    if !productContributors.contains(user) {
                        productContributors.add(user)
                    }
                    productContributors.contributors[productContributors.indexOf(user)!].role.isInformer = true
                }
                contributorsArray.append((ContributorTypes.InformersKey, users))
            }
        }
    }
    
    var productContributors = UniqueContributors()
    
    
    var contributorsArray: [(String,[String]?)] = []

    
    struct UniqueContributors {
        var contributors: [Contributor] = []
        
        func indexOf(name: String) -> Int? {
            for var index = 0; index < contributors.count; ++index {
                if contributors[index].name == name {
                    return index
                }
            }
            return nil
        }
        
        func contains(name: String) -> Bool {
            return indexOf(name) != nil ? true : false
        }
        
        mutating func add(name: String) {
            contributors.append(Contributor(name: name, role: ContributorRole()))
        }
    }

    
    struct Contributor {
        var name: String
        var role: ContributorRole
    }
    
    struct ContributorRole {
        var isPhotographer: Bool = false
        var isCreator: Bool = false
        var isCorrector: Bool = false
        var isEditor: Bool = false
        var isInformer: Bool = false
    }
    
    struct NutritionFactItem {
        var itemName: String? = nil
        var standardValue: String? = nil
        var standardValueUnit: String? = nil
        var servingValue: String? = nil
        var servingValueUnit: String? = nil
        
        func valid() -> Bool {
            return standardValue != nil && !standardValue!.isEmpty
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
    /*
    // completion states parameters
    struct CompletionState {
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
    */
    init() {
        barcode = BarcodeType.Undefined("")
        name = nil
        commonName = nil
        brandsArray = nil
        mainUrlThumb = nil
        mainUrl = nil
        packagingArray = nil
        ingredients = nil
        imageIngredientsSmallUrl = nil
        imageIngredientsUrl = nil
        allergens = nil
        traces = nil
        additives = nil
        labelArray = nil
        producer = nil
        ingredientsOrigin = nil
        producerCode = nil
        servingSize = nil
        nutritionFacts = []
        nutritionScore = nil
        imageNutritionSmallUrl = nil
        nutritionFactsImageUrl = nil
        nutritionGrade = nil
        purchaseLocation = nil
        stores = nil
        countries = nil
        additionDate = nil
        creator = nil
        state = CompletionState()
        primaryLanguage = nil
        categories = nil
        photographers = nil
        correctors = nil
        editors = nil
        informers = nil
        productContributors = UniqueContributors()
        contributorsArray = []

    }
// End product
}
