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
                if let index = productContributors.indexOf(user) {
                    productContributors.contributors[index].role.isCreator = true
                } else {
                    var newRole = ContributorRole()
                    newRole.isCreator = true
                    let newContributor = Contributor(name: user, role: newRole)
                    productContributors.contributors.append(newContributor)
                }
                contributorsArray.append((ContributorTypes.CreatorKey, [user]))
            }
        }
    }
    var state = completionState()
    var primaryLanguage: String? = nil

    // group parameters
    var categories: [String]? = nil
    
    // community parameters
    var photographers: [String]? = nil {
        didSet {
            if let users = photographers {
                for user in users {
                    if let index = productContributors.indexOf(user) {
                        productContributors.contributors[index].role.isPhotographer = true
                    } else {
                        var newRole = ContributorRole()
                        newRole.isPhotographer = true
                        let newContributor = Contributor(name: user, role: newRole)
                        productContributors.contributors.append(newContributor)
                    }
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
                    if let index = productContributors.indexOf(user) {
                        productContributors.contributors[index].role.isCorrector = true
                    } else {
                        var newRole = ContributorRole()
                        newRole.isCorrector = true
                        let newContributor = Contributor(name: user, role: newRole)
                        productContributors.contributors.append(newContributor)
                    }
                }
                contributorsArray.append((ContributorTypes.CorrectorKey, users))
            }
        }
    }

    var editors: [String]? = nil {
        didSet {
            if let users = editors {
                for user in users {
                    if let index = productContributors.indexOf(user) {
                        productContributors.contributors[index].role.isEditor = true
                    } else {
                        var newRole = ContributorRole()
                        newRole.isEditor = true
                        let newContributor = Contributor(name: user, role: newRole)
                        productContributors.contributors.append(newContributor)
                    }
                }
                contributorsArray.append((ContributorTypes.EditorsKey, users))
            }
        }
    }

    var informers: [String]? = nil {
        didSet {
            if let users = informers {
                for user in users {
                    if let index = productContributors.indexOf(user) {
                        productContributors.contributors[index].role.isInformer = true
                    } else {
                        var newRole = ContributorRole()
                        newRole.isInformer = true
                        let newContributor = Contributor(name: user, role: newRole)
                        productContributors.contributors.append(newContributor)
                    }
                }
                contributorsArray.append((ContributorTypes.InformersKey, users))
            }
        }
    }

    var checkers: [String]? = nil {
        didSet {
            if let users = checkers {
                for user in users {
                    if !productContributors.contains(user) {
                        productContributors.add(user)
                    }
                    productContributors.contributors[productContributors.indexOf(user)!].role.isPhotographer = true
                }
                contributorsArray.append((ContributorTypes.CheckersKey, users))
            }
        }
    }
    
    var productContributors = UniqueContributors()
    
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
        var isChecker: Bool = false
    }
    
    var contributorsArray: [(String,[String]?)] = []
    
    struct NutritionFactItem {
        var itemName: String? = nil
        var standardValue: String? = nil
        var standardValueUnit: String? = nil
        var servingValue: String? = nil
        var servingValueUnit: String? = nil
        
        func valid() -> Bool {
            return standardValue != nil && !standardValue!.isEmpty
            /*
            if standardValue != nil && !standardValue!.isEmpty {
                return true
            } else {
                return false
            }
            */
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
// End product
}
