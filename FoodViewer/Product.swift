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
    
    // MARK: - Identification variables
    
    var barcode: BarcodeType
    
    var name: String? = nil
    var nameLanguage = [String:String?]()

    var genericName: String? = nil
    var genericNameLanguage = [String:String?]()

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

    var mainImageUrl: NSURL? = nil
    var mainImageData: ImageFetchResult? = nil {
        didSet {
            if mainImageData != nil {
                NSNotificationCenter.defaultCenter().postNotificationName(Notification.MainImageSet, object:nil)
            }
        }
    }
    
    var primaryLanguageCode: String? = nil
    var languageCodes: [String] = []
    var languages: [String:String] = [:]
    
    // MARK: - Packaging variables
    
    var quantity: String? = nil
    var packagingArray: [String]? = nil
    
    // MARK: - Ingredients variables
    
    var ingredients: String?
    var ingredientsLanguage = [String:String]()
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
    // This includes the language prefix en:
    var allergenKeys: [String]? = nil
    
    // returns the allergenKeys array in the current locale
    var translatedAllergens: [String]? {
        get {
            if let validAllergenKeys = allergenKeys {
                var translatedAllergens:[String]? = []
                let preferredLanguage = NSLocale.preferredLanguages()[0]
                for allergenKey in validAllergenKeys {
                    if let translatedKey = OFFplists.manager.translateAllergens(allergenKey, language:preferredLanguage) {
                        translatedAllergens!.append(translatedKey)
                    } else {
                        translatedAllergens!.append(allergenKey)
                    }
                }
                return translatedAllergens
            }
            return nil
        }
    }
    var traceKeys: [String]? = nil
    
    // returns the allergenKeys array in the current locale
    var translatedTraces: [String]? {
        get {
            if let validTracesKeys = traceKeys {
                var translatedTraces:[String]? = []
                let preferredLanguage = NSLocale.preferredLanguages()[0]
                for tracesKey in validTracesKeys {
                    if let translatedKey = OFFplists.manager.translateAllergens(tracesKey, language:preferredLanguage) {
                        translatedTraces!.append(translatedKey)
                    } else {
                        translatedTraces!.append(tracesKey)
                    }
                }
                return translatedTraces
            }
            return nil
        }
    }

    var additives: [String]? = nil
    var labelArray: [String]? = nil
    
    // usage parameters
    var servingSize: String? = nil
    
    // MARK: - Nutrition variables 
    
    var nutritionFactsAreAvailable = NutritionAvailability.NotIndicated
    var nutritionFactsIndicationUnit: NutritionEntryUnit? = nil
    var nutritionFacts: [NutritionFactItem] = []
    var nutritionScore: [(NutritionItem, NutritionLevelQuantity)]? = nil
    var imageNutritionSmallUrl: NSURL? = nil
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
            nutritionImageData?.retrieveImageData(nutritionFactsImageUrl) { (fetchResult:ImageFetchResult?) in
                self.nutritionImageData = fetchResult
            }
        }
        return nutritionImageData
    }
    
    func getMainImageData() -> ImageFetchResult {
        if mainImageData == nil {
            // launch the image retrieval
            mainImageData = .Loading
            mainImageData?.retrieveImageData(mainImageUrl) { (fetchResult:ImageFetchResult?) in
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

    
    //MARK: - Supply chain variables
    
    var nutritionGrade: NutritionalScoreLevel? = nil
    var nutritionalScoreUK = NutritionalScoreUK()
    var nutritionalScoreFrance = NutritionalScoreFrance()
    var purchaseLocation: Address? = nil //or a set?
    
    func purchaseLocationElements(elements: [String]?) {
        if elements != nil && !elements!.isEmpty {
            self.purchaseLocation = Address()
            self.purchaseLocation!.elements = elements
        }
    }
    
    func purchaseLocationString(location: String?) {
        if let validLocationString = location {
            self.purchaseLocation = Address()
            self.purchaseLocation!.locationString = validLocationString

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
    var links: [NSURL]? = nil
    var expirationDate: NSDate? = nil
    
    func producerElements(elements: String?) {
        if elements != nil {
            let addressElements = elements?.characters.split{$0 == ","}.map(String.init)
            self.producer = Address()
            self.producer!.elements = addressElements
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
    
    // MARK: - Initialize functions
    
    init() {
        barcode = BarcodeType.Undefined("")
        name = nil
        genericName = nil
        brandsArray = nil
        mainUrlThumb = nil
        mainImageUrl = nil
        mainImageData = nil
        packagingArray = nil
        quantity = nil
        ingredients = nil
        imageIngredientsSmallUrl = nil
        imageIngredientsUrl = nil
        allergenKeys = nil
        traceKeys = nil
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
        primaryLanguageCode = nil
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
            nameLanguage = product.nameLanguage
            genericName = product.genericName
            genericNameLanguage = product.genericNameLanguage
            brandsArray = product.brandsArray
            mainUrlThumb = product.mainUrlThumb
            mainImageUrl = product.mainImageUrl
            mainImageData = nil
            packagingArray = product.packagingArray
            quantity = product.quantity
            ingredients = product.ingredients
            ingredientsLanguage = product.ingredientsLanguage
            imageIngredientsSmallUrl = product.imageIngredientsSmallUrl
            imageIngredientsUrl = product.imageIngredientsUrl
            ingredientsImageData = nil
            numberOfIngredients = product.numberOfIngredients
            allergenKeys = product.allergenKeys
            traceKeys = product.traceKeys
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
            primaryLanguageCode = product.primaryLanguageCode
            languageCodes = product.languageCodes
            languages = product.languages
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
    
    func regionURL() -> NSURL? {
        let region = NSBundle.mainBundle().preferredLocalizations[0] as NSString
        return NSURL(string: "http://\(region).openfoodfacts.org/en:product/" + barcode.asString() + "/")
    }
    
// End product
}
