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
    
    // Primary variables
    
    // MARK: - Identification variables
    
    var barcode: BarcodeType {
        didSet {
            if barcode.productType() == nil {
                barcode.setType(type)
            }
        }
    }
    
    // This variable returns the product name for the primary language
    var name: String? {
        get {
            if let validPrimaryLanguageCode = primaryLanguageCode {
                // In this way the primaryLanguageCode can change
                if nameLanguage[validPrimaryLanguageCode] != nil {
                    // If no name has been defined in this language, it will return nil
                    return nameLanguage[validPrimaryLanguageCode]!
                }
            }
            return nil
        }
    }
    
    var nameLanguage: [String:String?] = [:]

    var genericName: String? {
        get {
            if let validPrimaryLanguageCode = primaryLanguageCode {
                // In this way the primaryLanguageCode can change
                if genericNameLanguage[validPrimaryLanguageCode] != nil {
                    // If no name has been defined in this language, it will return nil
                    return genericNameLanguage[validPrimaryLanguageCode]!
                }
            }
            return nil
        }
    }
    
    var genericNameLanguage = [String:String?]()
    
    var brandsOriginal: Tags = .undefined
    var brandsInterpreted: Tags = .undefined
    
    var primaryLanguageCode: String? = nil {
        didSet {
            if let validLanguage = primaryLanguageCode {
                if !languageCodes.contains(validLanguage) {
                    // add the language if it does not exist yet
                    languageCodes.append(validLanguage)
                    set(newName: "", for: validLanguage)
                    set(newGenericName: "", for: validLanguage)
                    set(newIngredients: "", for: validLanguage)
                }
            }
        }
    }
    
    // dictionaries with languageCode as key
    var frontImages: [String:ProductImageSize] = [:]
    var nutritionImages: [String:ProductImageSize] = [:]
    var ingredientsImages: [String:ProductImageSize] = [:]
    // dictionary with image ID as key and the images in various sizes as value
    var images: [String:ProductImageSize] = [:]
    
    var languageCodes: [String] = []
    
    var languages: [String] {
        get {
            var languageList: [String] = []
            for languageCode in self.languageCodes {
                // TBD can this be set in the locale language?
                languageList.append(OFFplists.manager.languageName(for:languageCode))
            }
            return languageList.sorted(by: { $0 < $1 })
        }
    }
    
    var languageTags: Tags {
        get {
            return .available(languages)
        }
    }
    
    var languageCodeTags: Tags {
        get {
            return .available(languageCodes)
        }
    }

    // MARK: - Packaging variables
    
    var quantity: String? = nil
    var packagingInterpreted: Tags = .undefined
    var packagingOriginal: Tags = .undefined
    var packagingHierarchy: Tags = .undefined
    
    // MARK: - Ingredients variables
    
    var ingredients: String? {
        get {
            if let validPrimaryLanguageCode = primaryLanguageCode {
                // In this way the primaryLanguageCode can change
                if ingredientsLanguage[validPrimaryLanguageCode] != nil {
                    // If no name has been defined in this language, it will return nil
                    return ingredientsLanguage[validPrimaryLanguageCode]!
                }
            }
            return nil
        }
    }
    
    var ingredientsLanguage = [String:String]()
    
    var numberOfIngredients: String? = nil

    // This includes the language prefix en:
    // var allergenKeys: [String]? = nil
    
    // returns the allergenKeys array in the current locale
    var allergensTranslated: Tags {
        get {
            switch allergensInterpreted {
            case .available(let allergens):
                var translatedAllergens:[String] = []
                for allergenKey in allergens {
                    if let translatedKey = OFFplists.manager.translateAllergens(allergenKey, language:Locale.interfaceLanguageCode()) {
                        translatedAllergens.append(translatedKey)
                    } else if let translatedKey = OFFplists.manager.translateAllergens(allergenKey, language:Locale.preferredLanguages[0]) {
                            translatedAllergens.append(translatedKey)
                    } else {
                        translatedAllergens.append(allergenKey)
                    }
                }
                return translatedAllergens.count == 0 ? .empty : .available(translatedAllergens)
            default:
                break
            }
            return .undefined
        }
    }
    
    var allergensOriginal: Tags = .undefined
    var allergensHierarchy: Tags = .undefined
    var allergensInterpreted: Tags = .undefined
    
    var tracesOriginal: Tags = .undefined
    var tracesHierarchy: Tags = .undefined
    var tracesInterpreted: Tags = .undefined
    
    // returns the allergenKeys array in the current locale
    var tracesTranslated: Tags {
        get {
            switch tracesInterpreted {
            case .available(let traces):
                var translatedTraces:[String] = []
                for trace in traces {
//                    if let translatedKey = OFFplists.manager.translateAllergens(trace, language:Locale.interfaceLanguageCode()) {
//                        translatedTraces.append(translatedKey)
//                    } else
                        if let translatedKey = OFFplists.manager.translateAllergens(trace, language:Locale.preferredLanguages[0]) {
                            translatedTraces.append(translatedKey)
                    } else {
                        translatedTraces.append(trace)
                    }
                }
                return translatedTraces.count == 0 ? .empty : .available(translatedTraces)
            default:
                break
            }
            return .undefined
        }
    }
    
    var additivesInterpreted: Tags = .undefined
    var additivesOriginal: Tags = .undefined
    var additivesTranslated: Tags {
        get {
            switch additivesInterpreted {
            case .available(let additives):
                var translatedAdditives:[String] = []
                for additive in additives {
                    translatedAdditives.append(OFFplists.manager.translateAdditives(additive, language:Locale.preferredLanguages[0]))
                }
            return translatedAdditives.count == 0 ? .empty : .available(translatedAdditives)
            default:
                break
            }
            return .undefined
        }
    }
    var labelsInterpreted: Tags = .undefined
    var labelsOriginal: Tags = .undefined
    var labelsHierarchy: Tags = .undefined
    
    // usage parameters
    var servingSize: String? = nil
    
    // MARK: - Nutrition variables 
    
    var nutritionFactsAreAvailable: NutritionAvailability {
        get {
            // Figures out whether a nutrition fact contains values per serving and/or standard
            if let validNutritionFacts = nutritionFacts {
                if !validNutritionFacts.isEmpty {
                    if validNutritionFacts[0]?.servingValue != nil &&
                        !validNutritionFacts[0]!.servingValue!.isEmpty &&
                        validNutritionFacts[0]?.standardValue != nil &&
                        !validNutritionFacts[0]!.standardValue!.isEmpty {
                        return .perServingAndStandardUnit
                    } else if validNutritionFacts[0]?.servingValue != nil &&
                        !validNutritionFacts[0]!.servingValue!.isEmpty {
                        return .perServing
                    } else if validNutritionFacts[0]?.standardValue != nil &&
                        !validNutritionFacts[0]!.standardValue!.isEmpty {
                        return .perStandardUnit
                    }
                }
            }
            return .notIndicated
        }
    }
    
    // This variable indicates whether there are nutrition facts available on the package.
    var hasNutritionFacts: Bool? = nil // nil indicates that it is not known
    
    // hasNutritionFacts can be nil even if there are nutriments defined
    var nutrimentFactsAvailability: Bool {
        get {
            if hasNutritionFacts != nil {
                return hasNutritionFacts!
            } else {
                return nutritionFacts != nil ? true : false
            }
        }
    }
    var nutritionFactsIndicationUnit: NutritionEntryUnit? = nil
    
    // The nutritionFacts array can be nil, if nothing has been defined
    // An element in the array can be nil as well
    var nutritionFacts: [NutritionFactItem?]? = nil
    
    func add(fact: NutritionFactItem) {
        if nutritionFacts == nil {
            nutritionFacts = []
        }
        nutritionFacts?.append(fact)
        
    }
    
    var nutritionScore: [(NutritionItem, NutritionLevelQuantity)]? = nil
    //MARK: - Supply chain variables
    
    var nutritionGrade: NutritionalScoreLevel? = nil
    var nutritionalScoreUK: LocalizedNutritionalScoreUK? = nil
    var nutritionalScoreFR: LocalizedNutritionalScoreFR? = nil
    
    var purchasePlacesAddress: Address? = nil //or a set?
    var purchasePlacesInterpreted: Tags = .undefined
    var purchasePlacesOriginal: Tags = .undefined
    
    func purchaseLocationElements(_ elements: [String]?) {
        if elements != nil {
            if self.purchasePlacesAddress == nil {
                self.purchasePlacesAddress = Address()
            }
            self.purchasePlacesAddress?.rawArray = clean(elements!)
        }
    }
    
    func purchaseLocationString(_ location: String?) {
        if let validLocationString = location {
            self.purchasePlacesAddress = Address()
            self.purchasePlacesAddress!.locationString = validLocationString
        }
    }
    
    var storesOriginal: Tags = .undefined
    var storesInterpreted: Tags = .undefined
    
    var countriesAddress: [Address] {
        get {
            switch countriesOriginal {
            case .available(let countries):
                if !countries.isEmpty {
                    var addresses: [Address] = []
                    for country in countries {
                        if !country.isEmpty {
                            let newAddress = Address()
                            newAddress.raw = country
                            newAddress.country = country
                            addresses.append(newAddress)
                        }
                    }
                    return addresses
                }
                break
            default:
                break
            }
            return []
        }
    }
    
    var countriesOriginal: Tags = .undefined
    var countriesInterpreted: Tags = .undefined
    var countriesHierarchy: Tags = .undefined
    var countriesTranslated: Tags {
        get {
            switch countriesInterpreted {
            case .available(let countries):
                var translatedCountries:[String] = []
                let preferredLanguage = Locale.preferredLanguages[0]
                for country in countries {
                    let translatedKey = OFFplists.manager.translateCountries(country, language: preferredLanguage)
                    translatedCountries.append(translatedKey)
                }
                return translatedCountries.count == 0 ? .empty : Tags.init(translatedCountries)
            default:
                break
            }
            return .undefined
        }
    }
    
    var manufacturingPlacesAddress: Address? {
        get {
            switch manufacturingPlacesOriginal {
            case .available(let manufacturingPlace):
                if !manufacturingPlace.isEmpty {
                    let newAddress = Address()
                    newAddress.raw = manufacturingPlace.flatMap{ $0 }.joined(separator: ",")
                    return newAddress
                }
            default:
                break
            }
            return nil
        }
    }
    var manufacturingPlacesOriginal: Tags = .undefined
    var manufacturingPlacesInterpreted: Tags = .undefined
    
    var links: [URL]? = nil
    
    // this encodes the type of product, i.e. .food / .petFood / .beauty
    var server: String? = nil
    
    var type: ProductType? {
        
        // I should look in the history first to see if there is an associated type
        // If the product is created from the history there should be a product type
        if barcode.productType() != nil {
            return barcode.productType()
        }
        
        if let validServer = server {
            if validServer == "opff" {
                return .petFood
            } else if validServer == "obf" {
                return .beauty
            }
        }
        
        // does the main image contain info on product type?
        if let lan = primaryLanguageCode {
            if let imageResult = frontImages[lan]?.small {
                return imageResult.type()
            }
        }
        
        // Finally just return the current preference setting product type
        return currentProductType
    }
    
    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }

    var expirationDateString: String? = nil {
        didSet {
            expirationDate = decodeDate(expirationDateString)
        }
    }
    
    var expirationDate: Date? = nil


    fileprivate func decodeDate(_ date: String?) -> Date? {
        if let validDate = date {
            if !validDate.isEmpty {
                let types: NSTextCheckingResult.CheckingType = [.date]
                let dateDetector = try? NSDataDetector(types: types.rawValue)
                
                let dateMatches = dateDetector?.matches(in: validDate, options: [], range: NSMakeRange(0, (validDate as NSString).length))
                
                if let matches = dateMatches {
                    if !matches.isEmpty {
                        // did we find a date?
                        if matches[0].resultType == NSTextCheckingResult.CheckingType.date {
                            return matches[0].date
                        }
                    }
                }
                let dateFormatter = DateFormatter()
                // This is for formats not recognized by NSDataDetector
                // such as 07/2014
                // but other formats are possible and still need to be found
                if validDate.range( of: "../....", options: .regularExpression) != nil {
                    dateFormatter.dateFormat = "MM/yyyy"
                    return dateFormatter.date(from: validDate)
                } else if validDate.range( of: ".-....", options: .regularExpression) != nil {
                    dateFormatter.dateFormat = "MM/yyyy"
                    return dateFormatter.date(from: "0"+validDate)
                } else if validDate.range( of: "..-....", options: .regularExpression) != nil {
                    dateFormatter.dateFormat = "MM-yyyy"
                    return dateFormatter.date(from: validDate)
                } else if validDate.range( of: "....", options: .regularExpression) != nil {
                    dateFormatter.dateFormat = "yyyy"
                    return dateFormatter.date(from: validDate)
                } else if validDate.range( of: ". .... ....", options: .regularExpression) != nil {
                    dateFormatter.dateFormat = "dd MMM. yyyy"
                    return dateFormatter.date(from: validDate)
                }

                print("Date '\(validDate)' could not be recognized")
            }
        }
        return nil
    }
    
    var periodAfterOpeningString: String? = nil

    var periodAfterReferenceDate: Date? {
        get {
            return decodeInterval(periodAfterOpeningString)
        }
    }

    private func decodeInterval(_ interval: String?) -> Date? {
        if let validInterval = interval {
            if !validInterval.isEmpty {
                let intervalElements = validInterval.characters.split{$0 == " "}.map(String.init)
                if intervalElements[1] == "M" {
                    if let number = Double.init(intervalElements[0]) {
                    return Date.init(timeIntervalSinceReferenceDate: number * 3600.0 * 24.0 * 30.0)
                    }
                }
            }
        }
        return nil
    }
    
//    func producerElements(_ elements: String?) {
//        if elements != nil {
//            let addressElements = elements?.characters.split{$0 == ","}.map(String.init)
//            self.producer = Address()
//            self.producer!.rawArray = addressElements
//        }
//    }
//    
//    func producerElementsArray(_ elements: [String]?) {
//        if let validElements = elements {
//            self.producer = Address()
//            self.producer!.rawArray = validElements
//        }
//    }
    var originsOriginal: Tags = .undefined
    var originsInterpreted: Tags = .undefined
    var originsAddress: Address? {
        get {
            switch originsOriginal {
            case .available(let origin):
                if !origin.isEmpty {
                    let newAddress = Address()
                    newAddress.raw = origin.flatMap{ $0 }.joined(separator: ",")
                    return newAddress
                }
            default:
                break
            }
            return nil
        }
    }

//    func ingredientsOriginElements(_ elements: [String]?) {
//        self.ingredientsOrigin = Address()
//        self.ingredientsOrigin!.rawArray = elements
//    }

    //var producerCode: [Address]? = nil
    //var originalProducerCode: [Address]? = nil
    var embCodesInterpreted: Tags = .undefined
    var embCodesOriginal: Tags = .undefined
    
//    var producerCodeArray: [String]? = nil {
//        didSet {
//            if let validProducerCodes = producerCodeArray {
//                producerCode = []
//                for code in validProducerCodes {
//                    let newAddress = Address()
//                    newAddress.raw = code
//                    producerCode?.append(newAddress)
//                }
//            }
//        }
//    }
    
    // remove any empty items from the list
    private func clean(_ list: [String]) -> [String] {
        var newList: [String] = []
        if !list.isEmpty {
            for listItem in list {
                if listItem.characters.count > 0 {
                    newList.append(listItem)
                }
            }
        }
        return newList
    }

    var additionDate: Date? = nil
    var lastEditDates: [Date]? = nil
    
    var state = CompletionState()
    

    // group parameters
    var categoriesOriginal: Tags = .undefined
    var categoriesInterpreted: Tags = .undefined
    var categoriesHierarchy: Tags = .undefined
    var categoriesTranslated: Tags {
        get {
            switch categoriesInterpreted {
            case let .available(list):
                if !list.isEmpty {
                    var translatedList:[String] = []
                    let preferredLanguage = Locale.preferredLanguages[0]
                    for item in list {
                        translatedList.append(OFFplists.manager.translateCategories(item, language:preferredLanguage))
                    }
                    return .available(translatedList)
                } else {
                    return .empty
                }
            default:
                return .undefined
            }
        }
    }
    
    var creator: String? = nil {
        didSet {
            guard photographers != nil else { return }
            addUserRole(creator!, role: .creator)
        }
    }
    
    // community parameters
    var photographers: [String]? = nil {
        didSet {
            guard photographers != nil else { return }
            for name in photographers! {
                addUserRole(name, role: .photographer)
            }
        }
    }
    
    // community parameters
    var correctors: [String]? = nil {
        didSet {
            guard correctors != nil else { return }
            for name in correctors! {
                addUserRole(name, role: .corrector)
            }
        }
    }

    
    var editors: [String]? = nil {
        didSet {
            guard editors != nil else { return }
            for name in editors! {
                addUserRole(name, role: .editor)
            }
        }
    }

    var informers: [String]? = nil {
        didSet {
            guard informers != nil else { return }
            for name in informers! {
                addUserRole(name, role: .informer)
            }
        }
    }

    var contributors: [Contributor] = []
    
    func addUserRole(_ name: String, role: ContributorRole) {
        for (index, contributor) in contributors.enumerated() {
            if contributor.name == name {
                contributors[index].add(role)
                return
            }
        }
        if !name.isEmpty {
            contributors.append(Contributor(name, role: role))
        }
    }
    
    /*
    struct UniqueContributors {
        var contributors: [Contributor] = []
     
        func indexOf(_ name: String) -> Int? {
            for index in 0 ..< contributors.count {
                if contributors[index].name == name {
                    return index
                }
            }
            return nil
        }
        
        func contains(_ name: String) -> Bool {
            return indexOf(name) != nil ? true : false
        }
        
        mutating func add(_ name: String) {
            contributors.append(Contributor(name, role: .undefined))
        }
    }
 */

    // MARK: - Initialize functions
    
    init() {
        barcode = BarcodeType.undefined("", Preferences.manager.showProductType)
        brandsOriginal = .undefined
        brandsInterpreted = .undefined
        //mainUrlThumb = nil
        //mainImageUrl = nil
        //mainImageData = nil
        packagingHierarchy = .undefined
        packagingInterpreted = .undefined
        packagingOriginal = .undefined
        quantity = nil
        //imageIngredientsSmallUrl = nil
        //imageIngredientsUrl = nil
        allergensOriginal = .undefined
        allergensInterpreted = .undefined
        allergensHierarchy = .undefined
        tracesHierarchy = .undefined
        tracesOriginal = .undefined
        tracesInterpreted = .undefined
        additivesInterpreted = .undefined
        labelsOriginal = .undefined
        labelsHierarchy = .undefined
        labelsInterpreted = .undefined
        manufacturingPlacesOriginal = .undefined
        manufacturingPlacesInterpreted = .undefined
        originsOriginal = .undefined
        originsInterpreted = .undefined
        embCodesInterpreted = .undefined
        embCodesOriginal = .undefined
        servingSize = nil
        nutritionFacts = []
        nutritionScore = nil
        //imageNutritionSmallUrl = nil
        //nutritionFactsImageUrl = nil
        nutritionGrade = nil
        purchasePlacesAddress = nil
        purchasePlacesOriginal = .undefined
        purchasePlacesInterpreted = .undefined
        storesOriginal = .undefined
        storesInterpreted = .undefined
        countriesOriginal = .undefined
        countriesInterpreted = .undefined
        countriesHierarchy = .undefined
        additionDate = nil
        creator = nil
        state = CompletionState()
        primaryLanguageCode = nil
        languageCodes = []
        categoriesOriginal = .undefined
        categoriesInterpreted = .undefined
        categoriesHierarchy = .undefined
        photographers = nil
        correctors = nil
        editors = nil
        informers = nil
        hasNutritionFacts = nil
        contributors = []
    }
    
    init(withBarcode: BarcodeType) {
        self.barcode = withBarcode
    }
    
    init(product: FoodProduct) {
        self.barcode = product.barcode
        self.primaryLanguageCode = product.primaryLanguageCode
        // self.languageCodes = product.languageCodes

    }
    
    func nutritionFactsContain(_ key: String) -> Bool {
        if let validNutritionFacts = self.nutritionFacts {
            for fact in validNutritionFacts {
                if fact != nil && fact!.key == key {
                    return true
                }
            }

        }
        return false
    }
    
    // updates a product with new product data
    func updateDataWith(_ product: FoodProduct) {
        // all image data is set to nil, in order to force a reload
        
        // is it really the same product?
        if barcode.asString() == product.barcode.asString() {
            // Do I need to replace things, or should I carry out a check first?
            primaryLanguageCode = product.primaryLanguageCode
            nameLanguage = product.nameLanguage
            genericNameLanguage = product.genericNameLanguage
            brandsOriginal = product.brandsOriginal
            brandsInterpreted = product.brandsInterpreted
            frontImages = product.frontImages
            ingredientsImages = product.ingredientsImages
            nutritionImages = product.nutritionImages
            images = product.images
            packagingInterpreted = product.packagingInterpreted
            packagingOriginal = product.packagingOriginal
            packagingHierarchy = product.packagingHierarchy
            quantity = product.quantity
            ingredientsLanguage = product.ingredientsLanguage
            numberOfIngredients = product.numberOfIngredients
            allergensOriginal = product.allergensOriginal
            allergensInterpreted = product.allergensInterpreted
            allergensHierarchy = product.allergensHierarchy
            tracesInterpreted = product.tracesInterpreted
            tracesHierarchy = product.tracesHierarchy
            tracesOriginal = product.tracesOriginal
            additivesInterpreted = product.additivesInterpreted
            labelsInterpreted = product.labelsInterpreted
            labelsOriginal = product.labelsOriginal
            labelsHierarchy = product.labelsHierarchy
            manufacturingPlacesInterpreted = product.manufacturingPlacesInterpreted
            manufacturingPlacesOriginal = product.manufacturingPlacesOriginal
            originsOriginal = product.originsOriginal
            originsInterpreted = product.originsInterpreted
            embCodesInterpreted  = product.embCodesInterpreted
            embCodesOriginal  = product.embCodesOriginal
            servingSize = product.servingSize
            nutritionFacts = product.nutritionFacts
            nutritionScore = product.nutritionScore
            nutritionGrade = product.nutritionGrade
            purchasePlacesOriginal = product.purchasePlacesOriginal
            purchasePlacesAddress = product.purchasePlacesAddress
            purchasePlacesInterpreted = product.purchasePlacesInterpreted
            storesOriginal = product.storesOriginal
            storesInterpreted = product.storesInterpreted
            countriesOriginal = product.countriesOriginal
            countriesInterpreted = product.countriesInterpreted
            countriesHierarchy = product.countriesHierarchy
            additionDate = product.additionDate
            expirationDateString = product.expirationDateString
            creator = product.creator
            state = product.state
            languageCodes = product.languageCodes
            categoriesOriginal = product.categoriesOriginal
            categoriesInterpreted = product.categoriesInterpreted
            categoriesHierarchy = product.categoriesHierarchy
            photographers = product.photographers
            correctors = product.correctors
            editors = product.editors
            informers = product.informers
            contributors = product.contributors
            hasNutritionFacts = product.hasNutritionFacts
            // did I miss something?
        }
    }
    
    
    // updates a product with new product data
    func mergeUpdates(from product: FoodProduct?) {

        guard product != nil else { return }
        
        if product!.primaryLanguageCode != nil {
            primaryLanguageCode = product!.primaryLanguageCode
        }
        for languageSet in product!.nameLanguage {
            if languageSet.value != nil {
                nameLanguage[languageSet.key] = languageSet.value!
            }
        }
        for languageSet in product!.genericNameLanguage {
            if languageSet.value != nil {
                genericNameLanguage[languageSet.key] = languageSet.value!
            }
        }
        
        //if let validText = product!.searchText {
        //    searchText = validText
        //}
        
        switch product!.brandsOriginal {
        case .available(let list):
            brandsOriginal = Tags.init(list)
        default:
            break
        }
        // brandsInterpreted = product.brandsInterpreted
        // frontImages = product.frontImages
        // ingredientsImages = product.ingredientsImages
        // nutritionImages = product.nutritionImages
        // images = product.images
        switch product!.packagingOriginal {
        case .available(let list):
            packagingOriginal = Tags.init(list)
        default:
            break
        }
        // packagingInterpreted = product.packagingInterpreted
        // packagingHierarchy = product.packagingHierarchy
        // quantity = product.quantity
        for languageSet in product!.ingredientsLanguage {
            ingredientsLanguage[languageSet.key] = languageSet.value
        }
        // numberOfIngredients = product.numberOfIngredients
        switch product!.allergensOriginal {
        case .available(let list):
            allergensOriginal = Tags.init(list)
        default:
            break
        }
        // allergensInterpreted = product.allergensInterpreted
        // allergensHierarchy = product.allergensHierarchy
        switch product!.tracesOriginal {
        case .available(let list):
            tracesOriginal = Tags.init(list)
        default:
            break
        }
        // tracesInterpreted = product.tracesInterpreted
        // tracesHierarchy = product.tracesHierarchy
// additivesInterpreted = product.additivesInterpreted
        switch product!.labelsOriginal {
        case .available(let list):
            labelsOriginal = Tags.init(list)
        default:
            break
        }
        // labelsInterpreted = product.labelsInterpreted
        // labelsHierarchy = product.labelsHierarchy
        switch product!.manufacturingPlacesOriginal {
        case .available(let list):
            manufacturingPlacesOriginal = Tags.init(list)
        default:
            break
        }
        // manufacturingPlacesInterpreted = product.manufacturingPlacesInterpreted
        switch product!.originsOriginal {
        case .available(let list):
            originsOriginal = Tags.init(list)
        default:
            break
        }
        // originsInterpreted = product.originsInterpreted
        switch product!.embCodesOriginal {
        case .available(let list):
            embCodesOriginal = Tags.init(list)
        default:
            break
        }
        // embCodesInterpreted  = product.embCodesInterpreted
        // servingSize = product.servingSize
        // nutritionFacts = product.nutritionFacts
        // nutritionScore = product.nutritionScore
        // nutritionGrade = product.nutritionGrade
        switch product!.purchasePlacesOriginal {
        case .available(let list):
            purchasePlacesOriginal = Tags.init(list)
        default:
            break
        }
        // purchasePlacesAddress = product.purchasePlacesAddress
        // purchasePlacesInterpreted = product.purchasePlacesInterpreted
        switch product!.storesOriginal {
        case .available(let list):
            storesOriginal = Tags.init(list)
        default:
            break
        }
        // storesInterpreted = product.storesInterpreted
        switch product!.countriesOriginal {
        case .available(let list):
            countriesOriginal = Tags.init(list)
        default:
            break
        }
        // countriesInterpreted = product.countriesInterpreted
        // countriesHierarchy = product.countriesHierarchy
        if product!.additionDate != nil {
            additionDate = product!.additionDate
        }
        if product!.expirationDateString != nil {
            expirationDateString = product!.expirationDateString
        }
        if !product!.languageCodes.isEmpty {
            languageCodes = product!.languageCodes
        }
        switch product!.categoriesOriginal {
        case .available(let list):
            categoriesOriginal = Tags.init(list)
        default:
            break
        }
        // categoriesInterpreted = product.categoriesInterpreted
        // categoriesHierarchy = product.categoriesHierarchy
        if !product!.state.array.isEmpty {
            state = product!.state
        }
        if product!.creator != nil {
            creator = product!.creator
        }
        if product!.photographers != nil && !product!.photographers!.isEmpty {
            photographers = product!.photographers!
        }
        if product!.correctors != nil && !product!.correctors!.isEmpty {
            correctors = product!.correctors!
        }
        if product!.editors != nil && !product!.editors!.isEmpty {
            editors = product!.editors!
        }
        if product!.informers != nil && !product!.informers!.isEmpty {
            informers = product!.informers!
        }
    }

    
    //func worldURL() -> URL? {
    //    return URL(string: "http://world.openfoodfacts.org/product/" + barcode.asString() + "/")
    //}
    
    func regionURL() -> URL? {
        return URL(string: OFF.webProductURLFor(barcode))
    }
    
    func add(shop: String?) -> [String]? {
        if let validShop = shop {
            // are there any shops yet?
            switch storesOriginal {
            case .available(var stores):
                if !stores.isEmpty {
                    if !stores.contains(validShop) {
                        // there might be a shop with an empty string
                        if stores.count == 1 && stores[0].characters.count == 0 {
                            stores = [validShop]
                        } else {
                            stores.append(validShop)
                        }
                    }
                } else {
                    storesOriginal = Tags.init(stores)
                }
                storesOriginal = Tags.init(stores)
                return stores
            default:
                break
            }
        }
        return nil
    }
    
    func set(newName: String, for languageCode: String) {
        // is this the main language?
        //if languageCode == self.primaryLanguageCode {
        //    self.name = newName
        // }
        add(languageCode: languageCode)
        self.nameLanguage[languageCode] = newName
    }
    
    func set(newGenericName: String, for languageCode: String) {
        // is this the main language?
        //if languageCode == self.primaryLanguageCode {
        //    self.genericName = newGenericName
        //}
        add(languageCode: languageCode)
        self.genericNameLanguage[languageCode] = newGenericName
    }

    func set(newIngredients: String, for languageCode: String) {
        add(languageCode: languageCode)
        self.ingredientsLanguage[languageCode] = newIngredients
    }

    func add(languageCode: String) {
        // is this a new language?
        if !self.languageCodes.contains(languageCode) {
            self.languageCodes.append(languageCode)
        }
    }
    
    func contains(name: String, for languageCode: String) -> Bool {
        if nameLanguage[languageCode] != nil, nameLanguage[languageCode]! == name {
            return true
        }
        return false
    }
    
    func contains(genericName: String, for languageCode: String) -> Bool {
        if genericNameLanguage[languageCode] != nil, genericNameLanguage[languageCode]! == name {
            return true
        }
        return false
    }
    
    func contains(ingredients: String, in languageCode:String) -> Bool {
        return ingredients == self.ingredientsLanguage[languageCode] ? true : false
    }
    
    func contains(servingSize: String) -> Bool {
        return servingSize == self.servingSize ? true : false
    }
    
    func contains(barcode: String) -> Bool {
        return barcode == self.barcode.asString() ? true : false
    }

    
    func contains(expirationDate: Date) -> Bool {
        return expirationDate == self.expirationDate ? true : false
    }

    func contains(expirationDateString: String) -> Bool {
        return expirationDateString == self.expirationDateString ? true : false
    }

    func contains(primaryLanguageCode: String) -> Bool {
        return primaryLanguageCode == self.primaryLanguageCode ? true : false
    }

    func contains(languageCode: String) -> Bool {
        return languageCodes.contains(languageCode) ? true : false
    }

    func contains(shop: String) -> Bool {
        switch storesOriginal {
        case .available(let stores):
            return stores.contains(shop) ? true : false
        default:
            return false
        }
    }
    
    func contains(brands: [String]) -> Bool {
        switch self.brandsOriginal {
        case .available(let currentBrands):
            return Set.init(currentBrands) == Set.init(brands) ? true : false
        default:
            break
        }
        return false
    }
    
    func contains(packaging: [String]) -> Bool {
        switch self.packagingInterpreted {
        case .available(let currentpackagingArray):
            return Set.init(currentpackagingArray) == Set.init(packaging) ? true : false
        default:
            break
        }
        return false
    }

    func contains(traces: [String]) -> Bool {
        switch self.tracesOriginal {
        case .available(let currentTraces):
            return Set.init(currentTraces) == Set.init(traces) ? true : false
        default:
            break
        }
        return false
    }

    func contains(labels: [String]) -> Bool {
        switch self.labelsInterpreted {
        case .available(let currentLabels):
            return Set.init(currentLabels) == Set.init(labels) ? true : false
        default:
            break
        }
        return false
    }

    func contains(categories: [String]) -> Bool {
        switch self.categoriesOriginal {
        case .available(let currentCategories):
            return Set.init(currentCategories) == Set.init(categories) ? true : false
        default:
            break
        }
        return false
    }
    
    func contains(producer: [String]) -> Bool {
        switch self.manufacturingPlacesOriginal {
        case .available(let currentManufacturingPlaces):
            return Set.init(currentManufacturingPlaces) == Set.init(producer) ? true : false
        default:
            break
        }
        return false
    }

    func contains(producerCode: [String]) -> Bool {
        switch self.embCodesOriginal {
        case .available(let embCodes):
            return Set.init(embCodes) == Set.init(producerCode) ? true : false
        default:
            break
        }
        return false
    }

    func contains(ingredientsOrigin: [String]) -> Bool {
        switch self.originsOriginal {
        case .available(let origins):
            return Set.init(origins) == Set.init(ingredientsOrigin) ? true : false
        default:
            break
        }
        return false
    }
    
    func contains(stores: [String]) -> Bool {
        switch self.storesOriginal {
        case .available(let existingStores):
            return Set.init(existingStores) == Set.init(stores) ? true : false
        default:
            break
        }
        return false
    }

    func contains(purchaseLocation: [String]) -> Bool {
        switch self.purchasePlacesOriginal {
        case .available(let existingPurchasePlaces):
            return Set.init(existingPurchasePlaces) == Set.init(purchaseLocation) ? true : false
        default:
            break
        }
        return false
    }
    
    func contains(countries: [String]) -> Bool {
        switch self.countriesOriginal {
        case .available(let validCountries):
            return Set.init(validCountries) == Set.init(countries) ? true : false
        default:
            break
        }
        return false
    }

    func contains(links: [String]) -> Bool {
        if let validLinksArray = self.links?.map( { $0.absoluteString } ) {
            return Set.init(validLinksArray) == Set.init(links) ? true : false
        }
        return false
    }

    func contains(quantity: String) -> Bool {
        return quantity == self.quantity ? true : false
    }
    
    func contains(periodAfterOpeningString: String) -> Bool {
        return quantity == self.periodAfterOpeningString ? true : false
    }

    func contains(availability: Bool) -> Bool {
        return availability == self.hasNutritionFacts ? true : false
    }
    
    func translatedLabels() -> Tags {
        switch labelsInterpreted {
        case let .available(list):
            if !list.isEmpty {
                var translatedLabels:[String] = []
                let preferredLanguage = Locale.preferredLanguages[0]
                for label in list {
                        translatedLabels.append(OFFplists.manager.translateGlobalLabels(label, language:preferredLanguage))
                }
                return .available(translatedLabels)
            } else {
                return .empty
            }
        default:
            return .undefined
        }
    }

// End product
}

// Definition:
extension Notification.Name {
    static let MainImageSet = Notification.Name("FoodProduct.Notification.MainImageSet")
    static let IngredientsImageSet = Notification.Name("FoodProduct.Notification.IngredientsImageSet")
    static let NutritionImageSet = Notification.Name("FoodProduct.Notification.NutritionImageSet")
}

