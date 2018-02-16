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
                // If no name has been defined in this language, it will return nil
                return genericNameLanguage[validPrimaryLanguageCode] ?? nil
            }
            return nil
        }
    }
    
    var genericNameLanguage: [String:String?]  = [:]
    
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
    
    // dictionary with image ID as key and the images in the four sizes as value
    var images: [String:ProductImageSize] = [:]

    func imageID(for languageCode:String, in imageType: ImageTypeCategory) -> String? {
        for image in images {
            if image.value.isSelected(for: imageType, in: languageCode) {
                return image.key
            }
        }
        return nil
    }
    
    func image(for languageCode:String, of imageType:ImageTypeCategory) -> ProductImageData? {
        // is the image for the current language available im images?
        if let imageID = imageID(for:languageCode, in:imageType) {
            // then fetch the image
            return images[imageID]?.largest
            // try to use the primary image
        } else if let imageID = imageID(for:primaryLanguageCode!, in:imageType) {
             return images[imageID]?.largest
        }
        return nil
    }
    
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
    
    var ingredientsLanguage: [String:String?] = [:]
    
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
    
    func add(fact: NutritionFactItem?) {
        guard let validFact = fact else { return }
        if nutritionFacts == nil {
            nutritionFacts = []
        }
        nutritionFacts?.append(validFact)
        
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
                return translatedCountries.count == 0 ? .empty : Tags.init(list:translatedCountries)
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
                let intervalElements = validInterval.split(separator:" ").map(String.init)
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
                if listItem.count > 0 {
                    newList.append(listItem)
                }
            }
        }
        return newList
    }

    var additionDate: Date? = nil
    var lastEditDates: [Date]? = nil
    var imageAddDates: [Date] {
        var dates: Set<Date> = []
        for (_, imageData) in images {
            if let validDate = imageData.date {
                dates.insert(validDate)
            }
        }
        for (_, imageData) in frontImages {
            if let validDate = imageData.date {
                dates.insert(validDate)
            }
        }
        for (_, imageData) in ingredientsImages {
            if let validDate = imageData.date {
                dates.insert(validDate)
            }
        }
        for (_, imageData) in nutritionImages {
            if let validDate = imageData.date {
                dates.insert(validDate)
            }
        }
        return dates.sorted(by: { $0 > $1 })
    }
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
            guard creator != nil else { return }
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
    
    convenience init(with barcodeType: BarcodeType) {
        self.init()
        self.barcode = barcodeType
    }
    
    convenience init(json validProduct: OFFProductDetailed) {
        
        // checks whether a valid value is in the json-data
        func decodeNutritionDataAvalailable(_ code: String?) -> Bool? {
            if let validCode = code {
                // "no_nutrition_data":"on" indicates that there are NO nutriments on the package
                return validCode.hasPrefix("on") ? false : true
            }
            // not a valid json-code, so return do not know
            return nil
        }
        
        func decodeNutritionFactIndicationUnit(_ value: String?) -> NutritionEntryUnit? {
            if let validValue = value {
                if validValue.contains(NutritionEntryUnit.perStandardUnit.key) {
                    return .perStandardUnit
                } else if validValue.contains(NutritionEntryUnit.perServing.key) {
                    return .perServing
                }
            }
            return nil
        }

        func decodeLastEditDates(_ editDates: [String]?) -> [Date]? {
            if let dates = editDates {
                var uniqueDates = Set<Date>()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                dateFormatter.locale = Locale(identifier: "EN_en")
                // use only valid dates
                for date in dates {
                    // a valid date format is 2014-07-20
                    // I do no want the shortened dates in the array
                    if date.range( of: "...-..-..", options: .regularExpression) != nil {
                        if let newDate = dateFormatter.date(from: date) {
                            uniqueDates.insert(newDate)
                        }
                    }
                }
                return uniqueDates.sorted { $0.compare($1) == .orderedAscending }
            }
            return nil
        }

        func decodeCompletionStates(_ states: [OFFProductStates]?) {
            if let statesArray = states {
                for currentState in statesArray {
                    // only insert the states I want to use
                    switch currentState {
                    case .brands_completed,
                        .brands_to_be_completed,
                        .categories_completed,
                        .categories_to_be_completed,
                        .expiration_date_completed,
                        .expiration_date_to_be_completed,
                        .ingredients_completed,
                        .ingredients_to_be_completed,
                        .nutrition_facts_completed,
                        .nutrition_facts_to_be_completed,
                        .packaging_completed,
                        .packaging_to_be_completed,
                        .photos_to_be_uploaded,
                        .photos_uploaded,
                        .photos_validated,
                        .photos_to_be_validated,
                        .product_name_completed,
                        .product_name_to_be_completed,
                        .quantity_completed,
                        .quantity_to_be_completed:
                            state.states.insert(Completion(with: currentState))
                    default:
                        break
                    }
                }
            }
        }

        func decodeNutritionalScore(_ jsonString: String?) -> (LocalizedNutritionalScoreUK?, LocalizedNutritionalScoreFR?) {
            
            var nutrionalScoreUK: LocalizedNutritionalScoreUK? = nil
            var nutrionalScoreFrance: LocalizedNutritionalScoreFR? = nil
            
            if let validJsonString = jsonString {
                
                /* now parse the jsonString to create the right values
                 sample string:
                 0 --
                 1 --
                 0
                 0
                 energy 5
                 1   +
                 sat-fat 10
                 2   +
                 fr-sat-fat-for-fats 2
                 3   +
                 sugars 6
                 4   +
                 sodium 0
                 1   -
                 0
                 fruits
                 1
                 0%
                 2
                 0
                 2   -
                 0
                 fiber
                 1
                 4
                 3   -
                 proteins 4
                 2  --
                 0
                 fsa
                 1
                 17
                 3  --
                 fr 17"
                 */
                // print("\(validJsonString)")
                // is there useful info in the string?
                if (validJsonString.contains("-- energy ")) {
                    nutrionalScoreUK = LocalizedNutritionalScoreUK()
                    nutrionalScoreFrance = LocalizedNutritionalScoreFR()
                    // split on --, should give 4 parts: empty, nutriments, fsa, fr
                    let dashParts = validJsonString.components(separatedBy: "-- ")
                    var offset = 0
                    if dashParts.count == 5 {
                        offset = 1
                        if dashParts[1].contains("beverages") {
                            nutrionalScoreFrance?.beverage = true
                        } else if dashParts[1].contains("cheeses") {
                            nutrionalScoreFrance?.cheese = true
                        }
                    }
                    // find the total fsa score
                    var spaceParts2 = dashParts[2+offset].components(separatedBy: " ")
                    if let validScore = Int.init(spaceParts2[1]) {
                        nutrionalScoreUK?.score = validScore
                    } else {
                        nutrionalScoreUK?.score = 0
                    }
                    
                    spaceParts2 = dashParts[3+offset].components(separatedBy: " ")
                    if let validScore = Int.init(spaceParts2[1]) {
                        nutrionalScoreFrance?.score = validScore
                    } else {
                        nutrionalScoreFrance?.score = 0
                    }
                    
                    
                    if nutrionalScoreFrance != nil && nutrionalScoreFrance!.beverage {
                        // the french calculation for beverages uses a different table and evaluation
                        // use after the :
                        let colonParts = dashParts[1].components(separatedBy: ": ")
                        // split on +
                        let plusParts = colonParts[1].components(separatedBy: " + ")
                        // split on space to find the numbers
                        // energy
                        var spacePart = plusParts[0].components(separatedBy: " ")
                        if nutrionalScoreFrance != nil {
                            
                            if let validValue = Int.init(spacePart[1]) {
                                var newValue = nutrionalScoreFrance!.pointsA[0]
                                newValue.points = validValue
                                nutrionalScoreFrance!.pointsA[0] = newValue
                            }
                            // sat_fat
                            spacePart = plusParts[1].components(separatedBy: " ")
                            if let validValue = Int.init(spacePart[1]) {
                                var newValue = nutrionalScoreFrance!.pointsA[1]
                                newValue.points = validValue
                                nutrionalScoreFrance!.pointsA[1] = newValue
                            }
                            // sugars
                            spacePart = plusParts[2].components(separatedBy: " ")
                            if let validValue = Int.init(spacePart[1]) {
                                var newValue = nutrionalScoreFrance!.pointsA[2]
                                newValue.points = validValue
                                nutrionalScoreFrance!.pointsA[2] = newValue
                            }
                            // sodium
                            spacePart = plusParts[3].components(separatedBy: " ")
                            if let validValue = Int.init(spacePart[1]) {
                                var newValue = nutrionalScoreFrance!.pointsA[3]
                                newValue.points = validValue
                                nutrionalScoreFrance!.pointsA[3] = newValue
                            }
                        }
                        
                    } else {
                        if nutrionalScoreUK != nil && nutrionalScoreFrance != nil {
                            // split on -,
                            let minusparts = dashParts[1+offset].components(separatedBy: " - ")
                            
                            var spacePart = minusparts[1].components(separatedBy: " ")
                            // fruits 0%
                            if let validValue = Int.init(spacePart[2]) {
                                var newValueFrance = nutrionalScoreFrance!.pointsC[0]
                                var newValueUK = nutrionalScoreUK!.pointsC[0]
                                newValueFrance.points = validValue
                                newValueUK.points = validValue
                                nutrionalScoreFrance!.pointsC[0] = newValueFrance
                                nutrionalScoreUK!.pointsC[0] = newValueUK
                            }
                            // fiber
                            spacePart = minusparts[2].components(separatedBy: " ")
                            if let validValue = Int.init(spacePart[1]) {
                                var newValueFrance = nutrionalScoreFrance!.pointsC[1]
                                var newValueUK = nutrionalScoreUK!.pointsC[1]
                                newValueFrance.points = validValue
                                newValueUK.points = validValue
                                nutrionalScoreFrance!.pointsC[1] = newValueFrance
                                nutrionalScoreUK!.pointsC[1] = newValueUK
                            }
                            // proteins
                            spacePart = minusparts[3].components(separatedBy: " ")
                            if let validValue = Int.init(spacePart[1]) {
                                var newValueFrance = nutrionalScoreFrance!.pointsC[2]
                                var newValueUK = nutrionalScoreUK!.pointsC[2]
                                newValueFrance.points = validValue
                                newValueUK.points = validValue
                                nutrionalScoreFrance!.pointsC[2] = newValueFrance
                                nutrionalScoreUK!.pointsC[2] = newValueUK
                            }
                            
                            let plusParts = minusparts[0].components(separatedBy: " + ")
                            // energy
                            spacePart = plusParts[0].components(separatedBy: " ")
                            if let validValue = Int.init(spacePart[1]) {
                                var newValueFrance = nutrionalScoreFrance!.pointsA[0]
                                var newValueUK = nutrionalScoreUK!.pointsA[0]
                                newValueFrance.points = validValue
                                newValueUK.points = validValue
                                nutrionalScoreFrance!.pointsA[0] = newValueFrance
                                nutrionalScoreUK!.pointsA[0] = newValueUK
                            }
                            // saturated fats
                            spacePart = plusParts[1].components(separatedBy: " ")
                            if let validValue = Int.init(spacePart[1]) {
                                var newValueUK = nutrionalScoreUK!.pointsA[1]
                                newValueUK.points = validValue
                                nutrionalScoreUK!.pointsA[1] = newValueUK
                            }
                            // saturated fat ratio
                            spacePart = plusParts[2].components(separatedBy: " ")
                            if let validValue = Int.init(spacePart[1]) {
                                var newValueFrance = nutrionalScoreFrance!.pointsA[1]
                                newValueFrance.points = validValue
                                nutrionalScoreFrance!.pointsA[1] = newValueFrance
                            }
                            
                            // sugars
                            spacePart = plusParts[3].components(separatedBy: " ")
                            if let validValue = Int.init(spacePart[1]) {
                                var newValueFrance = nutrionalScoreFrance!.pointsA[2]
                                var newValueUK = nutrionalScoreUK!.pointsA[2]
                                newValueFrance.points = validValue
                                newValueUK.points = validValue
                                nutrionalScoreFrance!.pointsA[2] = newValueFrance
                                nutrionalScoreUK!.pointsA[2] = newValueUK
                            }
                            // sodium
                            spacePart = plusParts[4].components(separatedBy: " ")
                            if let validValue = Int.init(spacePart[1]) {
                                var newValueFrance = nutrionalScoreFrance!.pointsA[3]
                                var newValueUK = nutrionalScoreUK!.pointsA[3]
                                newValueFrance.points = validValue
                                newValueUK.points = validValue
                                nutrionalScoreFrance!.pointsA[3] = newValueFrance
                                nutrionalScoreUK!.pointsA[3] = newValueUK
                            }
                        }
                    }
                }
            }
            return (nutrionalScoreUK, nutrionalScoreFrance)
        }
        
        
        
        func nutritionDecode(_ key: NutrimentsFactKeys, with values: OFFProductNutrimentValues?) -> NutritionFactItem? {
            
            guard let validValues = values else { return nil }
            var nutritionItem = NutritionFactItem()
            
            //TODO: should be expressed as NutrimentFactKeys
            nutritionItem.key = key.rawValue
            
            // The translation of the key in the local language
            nutritionItem.itemName = OFFplists.manager.translateNutrients(key.rawValue, language:Locale.preferredLanguages[0])
            
            // Try to find the default unit for the current nutriment
            switch OFFplists.manager.nutrientUnit(for: key.rawValue) {
            case .Milligram, .Microgram:
                nutritionItem.standardValueUnit = .Gram
            default:
                nutritionItem.standardValueUnit = OFFplists.manager.nutrientUnit(for: key.rawValue)
            }
            nutritionItem.servingValueUnit = nutritionItem.standardValueUnit
            
            if let unit = nutritionItem.standardValueUnit {
                switch unit {
                case .Gram: // requires normalization
                    // per100g has already been transformed by OFF to gram
                    var (value, unit) = NutritionFactUnit.normalize(validValues.per100g)
                    nutritionItem.standardValue = value
                    nutritionItem.standardValueUnit = unit
                    
                    (value, unit) = NutritionFactUnit.normalize(validValues.serving)
                    nutritionItem.servingValue = value
                    nutritionItem.servingValueUnit = unit
                default: // does not require normalization
                    nutritionItem.standardValue = validValues.per100g
                    nutritionItem.servingValue = validValues.serving
                }
            }
            
            // only add a fact if it has valid values
            if nutritionItem.standardValue != nil || nutritionItem.servingValue != nil {
                return nutritionItem
            }
            return nil
        }


        self.init()
        
        barcode = BarcodeType.init(value: validProduct.code ?? "no code")

        primaryLanguageCode = validProduct.lang
        
        for (languageCode, _) in validProduct.languages_codes {
            languageCodes.append(languageCode)
        }
        
        decodeCompletionStates(validProduct.states_tags)
        
        lastEditDates = decodeLastEditDates(validProduct.last_edit_dates_tags)
        
        // the labels as interpreted by OFF (a list of strings)
        labelsInterpreted = Tags(list: validProduct.labels_tags)
        // the labels as the user has entered them (a comma delimited string)
        labelsOriginal = Tags(string: validProduct.labels)
        labelsHierarchy = Tags(list: validProduct.labels_hierarchy)
        
        tracesOriginal = Tags(string: validProduct.traces)
        tracesHierarchy = Tags(list: validProduct.traces_hierarchy)
        tracesInterpreted = Tags(list: validProduct.traces_tags)
        
        nameLanguage = validProduct.product_names_
        ingredientsLanguage = validProduct.ingredients_texts_
        genericNameLanguage = validProduct.generic_names_
        
        if let validImageSizes = validProduct.selected_images?.front {
            for (key, value) in validImageSizes.display {
                if frontImages[key] == nil {
                    frontImages[key] = ProductImageSize()
                }
                frontImages[key]?.display = ProductImageData(url: value)
            }

            for (key, value) in validImageSizes.thumb {
                if frontImages[key] == nil {
                    frontImages[key] = ProductImageSize()
                }
                frontImages[key]?.thumb = ProductImageData(url: value)
                _ = frontImages[key]?.thumb?.fetch()
            }

            for (key, value) in validImageSizes.small {
                if frontImages[key] == nil {
                    frontImages[key] = ProductImageSize()
                }
                frontImages[key]?.small = ProductImageData(url: value)
            }

        }

        if let validImageSizes = validProduct.selected_images?.nutrition {
            for (key, value) in validImageSizes.display {
                if nutritionImages[key] == nil {
                    nutritionImages[key] = ProductImageSize()
                }
                nutritionImages[key]?.display = ProductImageData(url: value)
            }

            for (key, value) in validImageSizes.thumb {
                if nutritionImages[key] == nil {
                    nutritionImages[key] = ProductImageSize()
                }
                nutritionImages[key]?.thumb = ProductImageData(url: value)
            }

            for (key, value) in validImageSizes.small {
                if nutritionImages[key] == nil {
                    nutritionImages[key] = ProductImageSize()
                }
                nutritionImages[key]?.small = ProductImageData(url: value)
            }

        }

        if let validImageSizes = validProduct.selected_images?.ingredients {

            for (key, value) in validImageSizes.display {
                if ingredientsImages[key] == nil {
                    ingredientsImages[key] = ProductImageSize()
                }
                ingredientsImages[key]?.display = ProductImageData(url: value)
            }

            for (key, value) in validImageSizes.thumb {
                if ingredientsImages[key] == nil {
                    ingredientsImages[key] = ProductImageSize()
                }
                ingredientsImages[key]?.thumb = ProductImageData(url: value)
            }

            for (key, value) in validImageSizes.small {
                if ingredientsImages[key] == nil {
                    ingredientsImages[key] = ProductImageSize()
                }
                ingredientsImages[key]?.small = ProductImageData(url: value)
            }
        }
        if let validImages = validProduct.images {
            for (key,value) in validImages {
                if !key.contains("ingredients") && !key.contains("front") && !key.contains("nutrition") {
                    let imageSet = ProductImageSize(for: barcode, and: key)
                    if images.contains(where: { $0.key == key }) {
                        images[key]?.thumb = imageSet.thumb
                        images[key]?.small = imageSet.small
                        images[key]?.display = imageSet.display
                        images[key]?.original = imageSet.original
                    } else {
                        images[key] = imageSet
                    }
                } else {
                    // add information on which image is a selected image for a specific language
                    // only look at key that have a language component
                    // parts[0] is the image type and parts[1] the languageCode
                    let parts = key.split(separator: "_")
                    // look only at elements that have a language component, i.e. count == 2
                    if parts.count > 1 && parts.count <= 2 {
                        let languageCode = String(parts[1])
                        if parts[0].contains("ingredients") {
                            if let localKey = value.imgid {
                                if !images.contains(where: { $0.key == localKey }) {
                                    images[localKey] = ProductImageSize()
                                }
                                images[localKey]?.usedIn.append((languageCode,.ingredients))
                            }
                        } else if parts[0].contains("front") {
                            if let localKey = value.imgid {
                                if !images.contains(where: { $0.key == localKey }) {
                                    images[localKey] = ProductImageSize()
                                }
                                images[localKey]?.usedIn.append((languageCode,.front))
                            }
                        } else if parts[0].contains("nutrition") {
                            if let localKey = value.imgid {
                                if !images.contains(where: { $0.key == localKey }) {
                                    images[localKey] = ProductImageSize()
                                }
                                images[localKey]?.usedIn.append((languageCode,.nutrition))
                            }
                        }
                    }
                }
                
            }

        }
        
        additivesInterpreted = Tags(list:validProduct.additives_tags)
        
        creator = validProduct.creator
        correctors = validProduct.correctors_tags
        informers = validProduct.informers_tags
        photographers = validProduct.photographers_tags
        editors = validProduct.editors_tags

        packagingInterpreted = Tags(list:validProduct.packaging_tags)
        packagingOriginal = Tags(string:validProduct.packaging)
        
        if let validInt = validProduct.ingredients_n {
            numberOfIngredients = "\(validInt)"
        }
        
        countriesOriginal = Tags(string:validProduct.countries)
        countriesInterpreted = Tags(list:validProduct.countries_tags)
        countriesHierarchy = Tags(list:validProduct.countries_hierarchy)
        
        embCodesOriginal = Tags(string:validProduct.emb_codes)
        embCodesInterpreted = Tags(list:validProduct.emb_codes_tags)
        
        brandsOriginal = Tags(string:validProduct.brands)
        brandsInterpreted = Tags(list:validProduct.brands_tags)
        
        // The links for the producer are stored as a string. This string might contain multiple links.
        let linksString = validProduct.link
        if let validLinksString = linksString {
            // assume that the links are separated by a comma ","
            let validLinksComponents = validLinksString.split(separator:",").map(String.init)
            links = []
            for component in validLinksComponents {
                if let validFirstURL = URL.init(string: component) {
                    links!.append(validFirstURL)
                }
            }
        }
        server = validProduct.server
        
        purchaseLocationString(validProduct.purchase_places)
        purchasePlacesInterpreted = Tags(list: validProduct.purchase_places_tags)
        purchasePlacesOriginal = Tags(string: validProduct.purchase_places)
        
        additionDate = validProduct.created_t
        hasNutritionFacts = decodeNutritionDataAvalailable(validProduct.no_nutrition_data)
        
        servingSize = validProduct.serving_size

        var grade: NutritionalScoreLevel = .undefined
        grade.string(validProduct.nutrition_grade_fr)
        nutritionGrade = grade
        
        storesOriginal = Tags(string: validProduct.stores)
        storesInterpreted = Tags(list: validProduct.stores_tags)
        
        (nutritionalScoreUK, nutritionalScoreFR) = decodeNutritionalScore(validProduct.nutrition_score_debug)
        
        originsInterpreted = Tags(list: validProduct.origins_tags)
        originsOriginal = Tags(string: validProduct.origins)
        
        manufacturingPlacesInterpreted = Tags(list: validProduct.manufacturing_places_tags)
        manufacturingPlacesOriginal = Tags(string: validProduct.manufacturing_places)
        
        categoriesOriginal = Tags(string: validProduct.categories)
        categoriesHierarchy = Tags(list: validProduct.categories_hierarchy)
        categoriesInterpreted = Tags(list: validProduct.categories_tags)
        
        quantity = validProduct.quantity
        nutritionFactsIndicationUnit = decodeNutritionFactIndicationUnit(validProduct.nutrition_data_per)
        
        periodAfterOpeningString = validProduct.period_after_opening
        
        expirationDateString = validProduct.expiration_date
        // This is need as the didSet of exirationDateString is not called in an init.
        expirationDate = decodeDate(expirationDateString)
        
        allergensInterpreted = Tags(list: validProduct.allergens_tags)
        allergensOriginal = Tags(string: validProduct.allergens)
        allergensHierarchy = Tags(list: validProduct.allergens_hierarchy)
        
        nutritionScore = [(NutritionItem.fat,
                           NutritionLevelQuantity.value(for:validProduct.nutrient_levels?.fat)),
                          (NutritionItem.saturatedFat,
                           NutritionLevelQuantity.value(for:validProduct.nutrient_levels?.saturated_fat)),
                          (NutritionItem.sugar,
                           NutritionLevelQuantity.value(for:validProduct.nutrient_levels?.sugars)),
                          (NutritionItem.salt,
                           NutritionLevelQuantity.value(for:validProduct.nutrient_levels?.salt))]

        // Warning: the order of these nutrients is important. It will be displayed as such.
        
        add(fact: nutritionDecode(.energyKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.EnergyKey]))
        add(fact: nutritionDecode(.fatKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.FatKey]))
        add(fact: nutritionDecode(.monounsaturatedFatKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.MonounsaturatedFatKey]))
        add(fact: nutritionDecode(.polyunsaturatedFatKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.PolyunsaturatedFatKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.saturatedFatKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.SaturatedFatKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.omega3FatKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.Omega3FatKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.omega6FatKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.Omega6FatKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.omega9FatKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.Omega9FatKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.transFatKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.TransFatKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.cholesterolKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.CholesterolKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.carbohydratesKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.CarbohydratesKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.sugarsKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.SugarsKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.sucroseKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.SucroseKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.glucoseKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.GlucoseKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.fructoseKey , with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.FructoseKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.lactoseKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.LactoseKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.maltoseKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.MaltoseKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.polyolsKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.PolyolsKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.maltodextrinsKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.MaltodextrinsKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.fiberKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.FiberKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.proteinsKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.ProteinsKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.sodiumKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.SodiumKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.saltKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.SaltKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.alcoholKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.AlcoholKey]))
        
        add(fact: nutritionDecode(NutrimentsFactKeys.biotinKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.BiotinKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.caseinKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.CaseinKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.serumProteinsKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.SerumProteinsKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.nucleotidesKey , with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.NucleotidesKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.starchKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.StarchKey]))
        
        add(fact: nutritionDecode(NutrimentsFactKeys.vitaminAKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.VitaminAKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.vitaminB1Key, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.VitaminB1Key]))
        add(fact: nutritionDecode(NutrimentsFactKeys.vitaminB2Key, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.VitaminB2Key]))
        add(fact: nutritionDecode(NutrimentsFactKeys.vitaminPPKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.VitaminPPKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.vitaminB6Key, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.VitaminB6Key]))
        add(fact: nutritionDecode(NutrimentsFactKeys.vitaminB9Key, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.VitaminB9Key]))
        add(fact: nutritionDecode(NutrimentsFactKeys.vitaminB12Key, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.VitaminB12Key]))
        add(fact: nutritionDecode(NutrimentsFactKeys.vitaminCKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.VitaminCKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.vitaminDKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.VitaminDKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.vitaminEKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.VitaminEKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.vitaminKKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.VitaminKKey]))
        
        add(fact: nutritionDecode(NutrimentsFactKeys.calciumKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.CalciumKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.chlorideKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.ChlorideKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.chromiumKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.ChromiumKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.copperKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.CopperKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.bicarbonateKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.BicarbonateKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.fluorideKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.FluorideKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.iodineKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.IodineKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.ironKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.IronKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.magnesiumKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.MagnesiumKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.manganeseKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.ManganeseKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.molybdenumKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.MolybdenumKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.phosphorusKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.PhosphorusKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.potassiumKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.PotassiumKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.seleniumKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.SeleniumKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.silicaKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.SilicaKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.zincKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.ZincKey]))
        
        add(fact: nutritionDecode(NutrimentsFactKeys.alphaLinolenicAcidKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.AlphaLinolenicAcidKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.arachidicAcidKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.ArachidicAcidKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.arachidonicAcidKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.ArachidonicAcidKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.behenicAcidKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.BehenicAcidKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.butyricAcidKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.ButyricAcidKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.capricAcidKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.CapricAcidKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.caproicAcidKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.CaproicAcidKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.caprylicAcidKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.CaprylicAcidKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.ceroticAcidKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.CeroticAcidKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.dihomoGammaLinolenicAcidKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.DihomoGammaLinolenicAcidKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.docosahexaenoicAcidKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.DocosahexaenoicAcidKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.eicosapentaenoicAcidKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.EicosapentaenoicAcidKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.elaidicAcidKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.ElaidicAcidKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.erucicAcidKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.ErucicAcidKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.gammaLinolenicAcidKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.GammaLinolenicAcidKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.gondoicAcidKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.GondoicAcidKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.lauricAcidKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.LauricAcidKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.lignocericAcidKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.LignocericAcidKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.linoleicAcidKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.LinoleicAcidKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.meadAcidKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.MeadAcidKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.melissicAcidKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.MelissicAcidKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.montanicAcidKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.MontanicAcidKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.myristicAcidKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.MyristicAcidKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.nervonicAcidKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.NervonicAcidKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.palmiticAcidKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.PalmiticAcidKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.pantothenicAcidKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.PantothenicAcidKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.stearicAcidKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.StearicAcidKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.voleicAcidKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.VoleicAcidKey]))
        
        add(fact: nutritionDecode(NutrimentsFactKeys.caffeineKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.CaffeineKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.taurineKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.TaurineKey]))
        
        add(fact: nutritionDecode(NutrimentsFactKeys.phKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.PhKey]))
        add(fact: nutritionDecode(NutrimentsFactKeys.cacaoKey, with: validProduct.nutriments?.nutriments[OFFReadAPIkeysJSON.CacaoKey]))
        
    }
    
    init(product: FoodProduct) {
        self.barcode = product.barcode
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
        if barcode.asString == product.barcode.asString {
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
            if product.hasNutritionFacts != nil && !product.hasNutritionFacts! {
                hasNutritionFacts = false
                nutritionFacts = nil
            } else {
                nutritionFacts = product.nutritionFacts
            }
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
            nameLanguage[languageSet.key] = languageSet.value
        }
        for languageSet in product!.genericNameLanguage {
            genericNameLanguage[languageSet.key] = languageSet.value
        }
        
        //if let validText = product!.searchText {
        //    searchText = validText
        //}
        
        switch product!.brandsOriginal {
        case .available(let list):
            brandsOriginal = Tags.init(list:list)
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
            packagingOriginal = Tags.init(list:list)
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
            allergensOriginal = Tags.init(list:list)
        default:
            break
        }
        // allergensInterpreted = product.allergensInterpreted
        // allergensHierarchy = product.allergensHierarchy
        switch product!.tracesOriginal {
        case .available(let list):
            tracesOriginal = Tags.init(list:list)
        default:
            break
        }
        // tracesInterpreted = product.tracesInterpreted
        // tracesHierarchy = product.tracesHierarchy
        // additivesInterpreted = product.additivesInterpreted
        switch product!.labelsOriginal {
        case .available(let list):
            labelsOriginal = Tags.init(list:list)
        default:
            break
        }
        // labelsInterpreted = product.labelsInterpreted
        // labelsHierarchy = product.labelsHierarchy
        switch product!.manufacturingPlacesOriginal {
        case .available(let list):
            manufacturingPlacesOriginal = Tags.init(list:list)
        default:
            break
        }
        // manufacturingPlacesInterpreted = product.manufacturingPlacesInterpreted
        switch product!.originsOriginal {
        case .available(let list):
            originsOriginal = Tags.init(list:list)
        default:
            break
        }
        // originsInterpreted = product.originsInterpreted
        switch product!.embCodesOriginal {
        case .available(let list):
            embCodesOriginal = Tags.init(list:list)
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
            purchasePlacesOriginal = Tags.init(list:list)
        default:
            break
        }
        // purchasePlacesAddress = product.purchasePlacesAddress
        // purchasePlacesInterpreted = product.purchasePlacesInterpreted
        switch product!.storesOriginal {
        case .available(let list):
            storesOriginal = Tags.init(list:list)
        default:
            break
        }
        // storesInterpreted = product.storesInterpreted
        switch product!.countriesOriginal {
        case .available(let list):
            countriesOriginal = Tags.init(list:list)
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
            categoriesOriginal = Tags.init(list:list)
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
                        if stores.count == 1 && stores[0].count == 0 {
                            stores = [validShop]
                        } else {
                            stores.append(validShop)
                        }
                    }
                } else {
                    storesOriginal = Tags.init(list:stores)
                }
                storesOriginal = Tags.init(list:stores)
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
        if let validIngredients = self.ingredientsLanguage[languageCode] {
            return ingredients == validIngredients ? true : false
        }
        return false
    }
    
    func contains(servingSize: String) -> Bool {
        return servingSize == self.servingSize ? true : false
    }
    
    func contains(barcode: String) -> Bool {
        return barcode == self.barcode.asString ? true : false
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

    // This calculated variable is needed for the creation of a OFF json
    var asOFFProductJson: OFFProductJson {
        
        var validNutritionFacts: [NutritionFactItem] = []
        if let existingNutritionFacts = self.nutritionFacts {
            for nutritionFact in existingNutritionFacts {
                if nutritionFact != nil {
                    validNutritionFacts.append(nutritionFact!)
                }
            }
        }
        
        let offNutriments = OFFProductNutriments(nutritionFacts: validNutritionFacts)
        var validLinks = ""
        if let validLinkUrls = self.links {
            for link in validLinkUrls {
                validLinks += link.absoluteString + ","
            }
        }
        
        var validNames: [String:String] = [:]
        for (languageCode, name) in self.nameLanguage {
            if let validName = name {
                validNames[languageCode] = validName
            }
        }
        
        var validGenericNames: [String:String] = [:]
        for (languageCode, name) in self.genericNameLanguage {
            if let validGenericName = name {
                validGenericNames[languageCode] = validGenericName
            }
        }

        var validIngredientsList: [String:String] = [:]
        for (languageCode, ingredients) in self.ingredientsLanguage {
            if let validIngredients = ingredients {
                validIngredientsList[languageCode] = validIngredients
            }
        }

        let offProduct = OFFProductDetailed.init(languageCodes: self.languageCodes,
                                                 names: validNames,
                                                 generic_names: validGenericNames,
                                                 ingredients: validIngredientsList,
                                                 additives_tags: self.additivesOriginal.list,
                                                 brands_tags: self.brandsOriginal.list,
                                                 categories_tags: self.categoriesOriginal.list,
                                                 code: self.barcode.asString,
                                                 countries_tags: self.countriesOriginal.list,
                                                 emb_codes_tags: self.embCodesOriginal.list,
                                                 expiration_date: self.expirationDateString ?? "",
                                                 labels_tags: self.labelsOriginal.list,
                                                 link: validLinks,
                                                 manufacturing_places_tags: self.manufacturingPlacesOriginal.list,
                                                 nutriments: offNutriments,
                                                 origins_tags: self.originsOriginal.list,
                                                 packaging_tags: self.packagingOriginal.list,
                                                 purchase_places_tags: self.purchasePlacesOriginal.list,
                                                 quantity: self.quantity ?? "",
                                                 serving_size: self.servingSize ?? "",
                                                 stores_tags: self.storesOriginal.list,
                                                 traces_tags: self.tracesOriginal.list )
        
        return OFFProductJson(product: offProduct, status: 1, code: self.barcode.asString, status_verbose: "Stored from FoodViewer")
    }

    // End product
}

// Definition:
extension Notification.Name {
    static let MainImageSet = Notification.Name("FoodProduct.Notification.MainImageSet")
    static let IngredientsImageSet = Notification.Name("FoodProduct.Notification.IngredientsImageSet")
    static let NutritionImageSet = Notification.Name("FoodProduct.Notification.NutritionImageSet")
}

