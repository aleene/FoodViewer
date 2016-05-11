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
        static let NutritionImageSet = "FoodProduct.Notification.NutritionImageSet"
    }
    
    // Primary variables
    
    // identification parameters
    var barcode: BarcodeType
    var name: String? = nil
    var commonName: String? = nil
    var brandsArray: [String]? = nil
    var mainUrlThumb: NSURL? {
        didSet {
            if let imageURL = mainUrlThumb {
                do {
                    let imageData = try NSData(contentsOfURL: imageURL, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                    if imageData.length > 0 {
                        mainImageSmallData = imageData
                    }
                }
                catch {
                    print(error)
                }
            }
        }
     }

     var mainImageSmallData: NSData? = nil

    var mainUrl: NSURL? = nil
    var mainImageData: ImageFetchResult? = nil {
        didSet {
            if mainImageData != nil {
                NSNotificationCenter.defaultCenter().postNotificationName(Notification.MainImageSet, object:nil)
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
    var ingredientsImageData: ImageFetchResult? = nil {
        didSet {
            if ingredientsImageData != nil {
                NSNotificationCenter.defaultCenter().postNotificationName(Notification.IngredientsImageSet, object: nil)
            }
        }
    }

    var allergens: [String]? = nil
    var traces: [String]? = nil
    var additives: [String]? = nil
    var labelArray: [String]? = nil
    
    // usage parameters
    var servingSize: String? = nil
    
    // content parameters
    var nutritionFacts: [NutritionFactItem] = []
    var nutritionScore: [(NutritionItem, NutritionLevelQuantity)]? = nil
    var imageNutritionSmallUrl: NSURL? = nil
        /*{
        didSet {
            if let imageURL = imageNutritionSmallUrl {
                do {
                    let imageData = try NSData(contentsOfURL: imageURL, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                    if imageData.length > 0 {
                            // if we have the image data we can go back to the main thread
                                // set the received image data to the current product if valid
                        self.nutritionImageSmallData = imageData
                    }
                }
                catch {
                    print(error)
                }
            }
        }
    }
 
    var nutritionImageSmallData: NSData? = nil
     */

    var nutritionFactsImageUrl: NSURL? = nil
    var nutritionImageData: ImageFetchResult? {
        didSet {
            if nutritionImageData != nil {
                NSNotificationCenter.defaultCenter().postNotificationName(Notification.NutritionImageSet, object: nil)
            }
        }
    }
    
    func getNutritionImageData() -> ImageFetchResult? {
        if nutritionImageData == nil {
            nutritionImageData = .Loading
            // launch the image retrieval
            nutritionImageData?.retrieveImageData(mainUrl) { (fetchResult:ImageFetchResult?) in
                self.nutritionImageData = fetchResult
            }
        }
        return nutritionImageData
    }
    
    func getMainImageData() -> ImageFetchResult {
        if mainImageData == nil {
            // launch the image retrieval
            mainImageData = .Loading
            mainImageData?.retrieveImageData(mainUrl) { (fetchResult:ImageFetchResult?) in
                self.mainImageData = fetchResult
            }
        }
        return mainImageData!
    }

    func getIngredientsImageData() -> ImageFetchResult {
        if ingredientsImageData == nil {
            // launch the image retrieval
            ingredientsImageData = .Loading
            ingredientsImageData?.retrieveImageData(imageIngredientsUrl) { (fetchResult:ImageFetchResult?) in
                self.ingredientsImageData = fetchResult
            }
        }
        return ingredientsImageData!
    }

    
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
    
    func countryArray(countries:[String]?) {
        if let array = countries {
            for element in array {
                if !element.isEmpty {
                    if self.countries == nil {
                        self.countries = []
                    }
                    let newAddress = Address()
                    newAddress.country = element
                    self.countries!.append(newAddress)
                }
            }
        }
    }

    var producer: Address? = nil
    var expirationDate: NSDate? = nil
    
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

    var producerCode: [Address]? = nil

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
        quantity = nil
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
    
    func nutritionFactsContain(nutritionFactToCheck: String) -> Bool {
        for fact in nutritionFacts {
            if fact.itemName == nutritionFactToCheck {
                return true
            }
        }
        return false
    }
    
    /*
    private func retrieveImageData(url: NSURL?, cont: ((ImageFetchResult?) -> Void)?) {
        if let imageURL = url {
            // self.nutritionImageData = .Loading
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                do {
                    // This only works if you add a line to your Info.plist
                    // See http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http
                    //
                    let imageData = try NSData(contentsOfURL: imageURL, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                    if imageData.length > 0 {
                        // if we have the image data we can go back to the main thread
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            // set the received image data to the current product if valid
                            cont?(.Success(imageData))
                            return
                        })
                    } else {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            // set the received image data to the current product if valid
                            cont?(.NoData)
                            return
                        })
                    }
                }
                catch {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        // set the received image data to the current product if valid
                        cont?(.LoadingFailed(error))
                        return
                    })
                }
            })
        } else {
            cont?(.NoData)
            return
        }
    }

    private func retrieveMainImageData() {
        if let imageURL = mainUrl {
            self.mainImageData = .Loading
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                do {
                    // This only works if you add a line to your Info.plist
                    // See http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http
                    //
                    let imageData = try NSData(contentsOfURL: imageURL, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                    if imageData.length > 0 {
                        // if we have the image data we can go back to the main thread
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            // set the received image data to the current product if valid
                            self.mainImageData = .Success(imageData)
                        })
                    } else {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            // set the received image data to the current product if valid
                            self.mainImageData = .NoData
                        })
                    }
                }
                catch {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        // set the received image data to the current product if valid
                        self.mainImageData = .LoadingFailed(error)
                    })
                }
            })
        } else {
            self.mainImageData = .NoData
        }
    }

    private func retrieveIngredientsImageData() {
        if let imageURL = imageIngredientsUrl {
            self.ingredientsImageData = .Loading
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                do {
                    // This only works if you add a line to your Info.plist
                    // See http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http
                    //
                    let imageData = try NSData(contentsOfURL: imageURL, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                    if imageData.length > 0 {
                        // if we have the image data we can go back to the main thread
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            // set the received image data to the current product if valid
                            self.ingredientsImageData = .Success(imageData)
                        })
                    } else {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            // set the received image data to the current product if valid
                            self.ingredientsImageData = .NoData
                        })

                    }
                    
                }
                catch {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        // set the received image data to the current product if valid
                        self.ingredientsImageData = .LoadingFailed(error)
                    })
                }
            })
        } else {
            self.mainImageData = .NoData

        }
    }
     */
    
    // updates a product with new product data
    func updateDataWith(product: FoodProduct) {
        // all image data is set to nil, in order to force a reload
        
        // is it really the same product?
        if barcode.asString() == product.barcode.asString() {
            name = product.name
            commonName = product.commonName
            brandsArray = product.brandsArray
            mainUrlThumb = product.mainUrlThumb
            mainUrl = product.mainUrl
            mainImageData = nil
            packagingArray = product.packagingArray
            quantity = product.quantity
            ingredients = product.ingredients
            imageIngredientsSmallUrl = product.imageIngredientsSmallUrl
            imageIngredientsUrl = product.imageIngredientsUrl
            ingredientsImageData = nil
            allergens = product.allergens
            traces = product.traces
            additives = product.additives
            labelArray = product.labelArray
            producer = product.producer
            ingredientsOrigin = product.ingredientsOrigin
            producerCode = product.producerCode
            servingSize = product.servingSize
            nutritionFacts = product.nutritionFacts
            nutritionScore = product.nutritionScore
            imageNutritionSmallUrl = product.imageNutritionSmallUrl
            nutritionFactsImageUrl = product.nutritionFactsImageUrl
            nutritionImageData = nil
            nutritionGrade = product.nutritionGrade
            purchaseLocation = product.purchaseLocation
            stores = product.stores
            countries = product.countries
            additionDate = product.additionDate
            expirationDate = product.expirationDate
            creator = product.creator
            state = product.state
            primaryLanguage = product.primaryLanguage
            categories = product.categories
            photographers = product.photographers
            correctors = product.correctors
            editors = product.editors
            informers = product.informers
            productContributors = product.productContributors
            contributorsArray = product.contributorsArray
            // did I miss something?
        }
    }
    
    func worldURL() -> NSURL? {
        return NSURL(string: "http://world.openfoodfacts.org/product/" + barcode.asString() + "/")
    }
    
    
// End product
}
