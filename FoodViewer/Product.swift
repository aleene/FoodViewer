//
//  Product.swift
//  FoodViewer
//
//  Created by arnaud on 30/01/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation
import MapKit

class FoodProduct {
    
    internal struct Notification {
        static let MainImageSet = "FoodProduct.Notification.MainImageSet"
        static let IngredientsImageSet = "FoodProduct.Notification.IngredientsImageSet"
    }
    
    // Primary variables
    
    // identification parameters
    var barcode: BarcodeType
    var name: String? = nil
    var commonName: String? = nil
    var brandsArray: [String]? = nil
    var mainUrlThumb: NSURL?    
    var mainUrl: NSURL? = nil
    var mainImageData: NSData? = nil {
        didSet {
            if mainImageData != nil {
                NSNotificationCenter.defaultCenter().postNotificationName(Notification.MainImageSet, object: nil)
            }
        }
    }
    
    // packaging parameters
    var quantity: String? = nil
    var packagingArray: [String]? = nil
    
    // ingredients parameters
    var ingredients: String?
    var numberOfIngredients: String? = nil
    var imageIngredientsSmallUrl: NSURL?
    var imageIngredientsUrl: NSURL? = nil
    var ingredientsImageData: NSData? = nil {
        didSet {
            if mainImageData != nil {
                NSNotificationCenter.defaultCenter().postNotificationName(Notification.MainImageSet, object: nil)
            }
        }
    }

    var allergens: [[String: String]]? = nil
    var traces: [[String: String]]? = nil
    var additives: [[String: String]]? = nil
    var labelArray: [[String: String]]? = nil
    
    // usage parameters
    var servingSize: String? = nil
    
    // content parameters
    var nutritionFacts: [NutritionFactItem] = []
    var nutritionScore: [(NutritionItem, NutritionLevelQuantity)]? = nil
    var imageNutritionSmallUrl: NSURL?
    var nutritionFactsImageUrl: NSURL?
    
    // supply chain parameters
    var nutritionGrade: NutritionalGradeLevel? = nil
    var purchaseLocation: Address? = nil //or a set?
    
    func purchaseLocationElements(elements: [String]?) {
        if elements != nil && !elements!.isEmpty {
            self.purchaseLocation = Address()
            self.purchaseLocation!.elements = elements
        }
    }
    
    var stores: [String]? = nil //or a set?
    var countries: [Address]? = nil //or a set?
    
    func languageCountryArray(countries:[String]?) {
        if let array = countries {
            for element in array {
                if !element.isEmpty {
                    if self.countries == nil {
                        self.countries = []
                    }
                    let newAddress = Address()
                    newAddress.languageCountry = element
                    self.countries!.append(newAddress)
                }
            }
        }
    }

    var producer: Address? = nil
    
    func producerElements(elements: [String]?) {
        if elements != nil && !elements!.isEmpty {
            self.producer = Address()
            self.producer!.elements = elements
        }
    }
    
    var ingredientsOrigin: Address? = nil
    
    func ingredientsOriginElements(elements: [String]?) {
        if elements != nil && !elements!.isEmpty {
            self.ingredientsOrigin = Address()
            self.ingredientsOrigin!.elements = elements
        }
    }

    var producerCode: [String]? = nil

    // contributor parameters
    var additionDate: NSDate? = nil
    var lastEditDates: [NSDate]? = nil
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
    var categories: [[String: String]]? = nil
    
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
            for index in 0 ..< contributors.count {
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
    
    
    init() {
        barcode = BarcodeType.Undefined("")
        name = nil
        commonName = nil
        brandsArray = nil
        mainUrlThumb = nil
        mainUrl = nil
        mainImageData = nil
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
    
    init(withBarcode: BarcodeType) {
        self.barcode = withBarcode
    }
    
// End product
}
