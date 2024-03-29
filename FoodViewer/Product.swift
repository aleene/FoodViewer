//
//  Product.swift
//  FoodViewer
//
//  Created by arnaud on 30/01/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation
import MapKit

enum NutritionFactsPreparationStyle: Int {
    case unprepared = 0
    case prepared
    
    var description: String {
        switch self {
        case .prepared:
            return TranslatableStrings.PreparationPrepared
        case .unprepared:
            return TranslatableStrings.PreparationUnprepared
        }
    }
}

class FoodProduct {
    
    // Primary variables
    
    // MARK: - Identification variables
    
    var barcode: BarcodeType {
        didSet {
            if barcode.productType == nil {
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
                    //set(newName: "", for: validLanguage)
                    //set(newGenericName: "", for: validLanguage)
                    //set(newIngredients: "", for: validLanguage)
                }
            }
        }
    }
    
    func matchedLanguageCode(codes:[String]) -> String? {
        for code in codes {
            if languageCodes.contains(code) {
                return code
            }
        }
        return primaryLanguageCode
    }
    
// MARK: - image variables and functions
    
    // dictionaries with languageCode as key
    var frontImages: [String:ProductImageSize] = [:]
    var nutritionImages: [String:ProductImageSize] = [:]
    var ingredientsImages: [String:ProductImageSize] = [:]
    var packagingImages: [String:ProductImageSize] = [:]

    // dictionary with image ID as key and the images in the four sizes as value
    var images: [String:ProductImageSize] = [:]

    func imageID(imageType: ImageTypeCategory) -> String? {
        return findImageID(languageCode: imageType.associatedString,
        imageType: imageType.description)
    }
    
/** Provides the image set corresponding to a languageCode and image type. If it does not exist a nil is returned.
- parameters:
     - imageType : the type of image (.front, .ingredients, .nutrition, .packaging)
*/
    public func image(imageType: ImageTypeCategory) -> ProductImageSize? {
        // is the image for the current language available im images?
        if let imageID = imageID(imageType: imageType) {
            return images[imageID]
        }
        return nil
    }
        
    public func imageID(for robotoffID: String?) -> String? {
        guard let validID = robotoffID else { return nil }
        let split = validID.split(separator: "_")
        guard split.count <= 2 else { return nil }
        guard split.count > 1 else { return validID }
        if split[0] == "front"
            || split[0] == "ingredients"
            || split[0] == "nutrition" {
            return findImageID(languageCode: String(split[1]),
                           imageType: String(split[0]))
        } else {
            return nil
        }
    }
    
    // Is this the same as imageID?
    private func findImageID(languageCode: String, imageType: String) -> String? {
        for (key, image) in images {
            for usedIn in image.usedIn {
                if usedIn == ImageTypeCategory.type(typeString: imageType, associated: languageCode)  {
                    return key
                }
            }
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
    var ingredientsTags: Tags = .undefined
    var ingredientsTranslated: Tags {
        get {
            switch ingredientsTags {
            case .available(let ingredients):
                var translatedIngredients:[String] = []
                for key in ingredients {
                    if let translatedKey = OFFplists.manager.translateIngredient(key, language:Locale.interfaceLanguageCode) {
                        translatedIngredients.append(translatedKey)
                    } else if let translatedKey = OFFplists.manager.translateIngredient(key, language:Locale.preferredLanguages[0]) {
                        translatedIngredients.append(translatedKey)
                    } else {
                        translatedIngredients.append(key)
                    }
                }
                return translatedIngredients.count == 0 ? .empty : .available(translatedIngredients)
            default:
                break
            }
            return .undefined
        }
    }

    var ingredientsHierarchy: Tags = .undefined
    var ingredientsHierarchyTranslated: Tags {
        get {
            switch ingredientsHierarchy {
            case .available(let ingredients):
                var translatedIngredients:[String] = []
                for key in ingredients {
                    if let translatedKey = OFFplists.manager.translateIngredient(key, language:Locale.interfaceLanguageCode) {
                        translatedIngredients.append(translatedKey)
                    } else if let translatedKey = OFFplists.manager.translateIngredient(key, language:Locale.preferredLanguages[0]) {
                        translatedIngredients.append(translatedKey)
                    } else {
                        translatedIngredients.append(key)
                    }
                }
                return translatedIngredients.count == 0 ? .empty : .available(translatedIngredients)
            default:
                break
            }
            return .undefined
        }
    }

    var numberOfIngredients: String? = nil

    var containsPalm: Bool = false
    var mightContainPalm: Bool = false

    // This includes the language prefix en:
    // var allergenKeys: [String]? = nil
    
    // returns the allergenKeys array in the current locale
    var allergensTranslated: Tags {
        get {
            switch allergensInterpreted {
            case .available(let allergens):
                var translatedAllergens:[String] = []
                for allergenKey in allergens {
                    if let translatedKey = OFFplists.manager.translateAllergen(allergenKey, language:Locale.interfaceLanguageCode) {
                        translatedAllergens.append(translatedKey)
                    } else if let translatedKey = OFFplists.manager.translateAllergen(allergenKey, language:Locale.preferredLanguages[0]) {
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
    
    // returns the allergenKeys array in the current locale
    var allergensHierarchyTranslated: Tags {
        get {
            switch allergensHierarchy {
            case .available(let allergens):
                var translatedAllergens:[String] = []
                for allergenKey in allergens {
                    if let translatedKey = OFFplists.manager.translateAllergen(allergenKey, language:Locale.interfaceLanguageCode) {
                        translatedAllergens.append(translatedKey)
                    } else if let translatedKey = OFFplists.manager.translateAllergen(allergenKey, language:Locale.preferredLanguages[0]) {
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
    
    /// returns the allergenKeys array in the current locale
    var tracesTranslated: Tags {
        get {
            switch tracesInterpreted {
            case .available(let traces):
                var translatedTraces:[String] = []
                for trace in traces {
//                    if let translatedKey = OFFplists.manager.translateAllergens(trace, language:Locale.interfaceLanguageCode()) {
//                        translatedTraces.append(translatedKey)
//                    } else
                    if let translatedKey = OFFplists.manager.translateAllergen(trace, language:Locale.preferredLanguages[0]) {
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
    
    // returns the allergenKeys array in the current locale
    var tracesHierarchyTranslated: Tags {
        get {
            switch tracesHierarchy {
            case .available(let traces):
                var translatedTraces:[String] = []
                for trace in traces {
                    //                    if let translatedKey = OFFplists.manager.translateAllergens(trace, language:Locale.interfaceLanguageCode()) {
                    //                        translatedTraces.append(translatedKey)
                    //                    } else
                    if let translatedKey = OFFplists.manager.translateAllergen(trace, language:Locale.preferredLanguages[0]) {
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
                    translatedAdditives.append(OFFplists.manager.translateAdditive(additive, language:Locale.preferredLanguages[0]) ?? additive)
                }
            return translatedAdditives.count == 0 ? .empty : .available(translatedAdditives)
            default:
                break
            }
            return .undefined
        }
    }
    
    var minerals: Tags = .undefined
    var mineralsTranslated: Tags {
        get {
            switch minerals {
            case .available(let minerals):
                var translatedMinerals:[String] = []
                for mineral in minerals {
                    if let translatedKey = OFFplists.manager.translateMineral(mineral, language:Locale.interfaceLanguageCode) {
                        translatedMinerals.append(translatedKey)
                    } else if let translatedKey = OFFplists.manager.translateMineral(mineral, language:Locale.preferredLanguages[0]) {
                        translatedMinerals.append(translatedKey)
                    } else {
                        translatedMinerals.append(mineral)
                    }
                }
                return translatedMinerals.count == 0 ? .empty : .available(translatedMinerals)
            default:
                break
            }
            return .undefined
        }
    }
    var aminoAcids: Tags = .undefined
    var aminoAcidsTranslated: Tags {
        get {
            switch aminoAcids {
            case .available(let aminoAcids):
                var translatedAminoAcids:[String] = []
                for aminoAcid in aminoAcids {
                    if let translatedKey = OFFplists.manager.translateAminoAcid(aminoAcid, language:Locale.interfaceLanguageCode) {
                        translatedAminoAcids.append(translatedKey)
                    } else if let translatedKey = OFFplists.manager.translateAminoAcid(aminoAcid, language:Locale.preferredLanguages[0]) {
                        translatedAminoAcids.append(translatedKey)
                    } else {
                        translatedAminoAcids.append(aminoAcid)
                    }
                }
                return translatedAminoAcids.count == 0 ? .empty : .available(translatedAminoAcids)
            default:
                break
            }
            return .undefined
        }
    }

    var vitamins: Tags = .undefined
    var vitaminsTranslated: Tags {
        get {
            switch vitamins {
            case .available(let vitamins):
                var translatedVitamins:[String] = []
                for vitamin in vitamins {
                    if let translatedKey = OFFplists.manager.translateVitamin(vitamin, language:Locale.interfaceLanguageCode) {
                        translatedVitamins.append(translatedKey)
                    } else if let translatedKey = OFFplists.manager.translateVitamin(vitamin, language:Locale.preferredLanguages[0]) {
                        translatedVitamins.append(translatedKey)
                    } else {
                        translatedVitamins.append(vitamin)
                    }
                }
                return translatedVitamins.count == 0 ? .empty : .available(translatedVitamins)
            default:
                break
            }
            return .undefined
        }
    }
    var nucleotides: Tags = .undefined
    var nucleotidesTranslated: Tags {
        get {
            switch nucleotides {
            case .available(let nucleotides):
                var translatedNucleotides:[String] = []
                for nucleotide in nucleotides {
                    if let translatedKey = OFFplists.manager.translateNucleotide(nucleotide, language:Locale.interfaceLanguageCode) {
                        translatedNucleotides.append(translatedKey)
                    } else if let translatedKey = OFFplists.manager.translateNucleotide(nucleotide, language:Locale.preferredLanguages[0]) {
                        translatedNucleotides.append(translatedKey)
                    } else {
                        translatedNucleotides.append(nucleotide)
                    }
                }
                return translatedNucleotides.count == 0 ? .empty : .available(translatedNucleotides)
            default:
                break
            }
            return .undefined
        }
    }
    var otherNutritionalSubstances: Tags = .undefined
    var otherNutritionalSubstancesTranslated: Tags {
        get {
            switch otherNutritionalSubstances {
            case .available(let otherNutritionalSubstances):
                var translatedOther:[String] = []
                for otherNutritionalSubstance in otherNutritionalSubstances {
                    if let translatedKey = OFFplists.manager.translateNucleotide(otherNutritionalSubstance, language:Locale.interfaceLanguageCode) {
                        translatedOther.append(translatedKey)
                    } else if let translatedKey = OFFplists.manager.translateNucleotide(otherNutritionalSubstance, language:Locale.preferredLanguages[0]) {
                        translatedOther.append(translatedKey)
                    } else {
                        translatedOther.append(otherNutritionalSubstance)
                    }
                }
                return translatedOther.count == 0 ? .empty : .available(translatedOther)
            default:
                break
            }
            return .undefined
        }
    }

    var labelsInterpreted: Tags = .undefined
    var labelsOriginal: Tags = .undefined
    var labelsHierarchy: Tags = .undefined
    var labelsTranslated: Tags {
        get {
            switch labelsInterpreted {
            case .available(let labels):
                var translatedLabels:[String] = []
                for label in labels {
                    if let translatedKey = OFFplists.manager.translateGlobalLabel(label, language:Locale.interfaceLanguageCode) {
                        translatedLabels.append(translatedKey)
                    } else if let translatedKey = OFFplists.manager.translateGlobalLabel(label, language:Locale.preferredLanguages[0]) {
                        translatedLabels.append(translatedKey)
                    } else {
                        translatedLabels.append(label)
                    }
                }
                return translatedLabels.count == 0 ? .empty : .available(translatedLabels)
            default:
                break
            }
            return .undefined
        }
    }
    
    var labelsHierarchyTranslated: Tags {
        get {
            switch labelsHierarchy {
            case .available(let labels):
                var translatedLabels:[String] = []
                for label in labels {
                    if let translatedKey = OFFplists.manager.translateGlobalLabel(label, language:Locale.interfaceLanguageCode) {
                        translatedLabels.append(translatedKey)
                    } else if let translatedKey = OFFplists.manager.translateGlobalLabel(label, language:Locale.preferredLanguages[0]) {
                        translatedLabels.append(translatedKey)
                    } else {
                        translatedLabels.append(label)
                    }
                }
                return translatedLabels.count == 0 ? .empty : .available(translatedLabels)
            default:
                break
            }
            return .undefined
        }
    }

    // usage parameters
    var servingSize: String? = nil
    
    // MARK: - Nutrition variables 
    
    var nutritionFacts: [NutritionFactsPreparationStyle: Set<NutritionFactItem>] = [:]
    
    var nutritionFactsAreAvailable: NutritionAvailability {
        get {
            // Figures out whether a nutrition fact contains values per serving and/or standard
            // We use the first nutritionfact that is available and check the OFF processed data
            for nutrientSet in nutritionFacts {
                if let firstNutrient = nutrientSet.value.first {
                    if let firstServing = firstNutrient.serving,
                        let firstStandard = firstNutrient.standard,
                        !firstServing.isEmpty && !firstStandard.isEmpty {
                        return .perServingAndStandardUnit
                    } else if let first = firstNutrient.serving,
                        !first.isEmpty {
                        return .perServing
                    } else if let first = firstNutrient.standard,
                        !first.isEmpty {
                        return .perStandardUnit
                    }
                }
            }
            if hasNutritionFacts != nil {
                return .notIndicated
            }
            return .notAvailable
        }
    }
    
    /// This variable indicates whether there are nutrition facts available on the package.
    public var hasNutritionFacts: Bool? = nil // nil indicates that it is not known/provided by OFF
    
    /// hasNutritionFacts can be nil even if there are nutriments defined
    var nutrimentFactsAvailability: Bool {
        get {
            if let hasFacts = hasNutritionFacts {
                return hasFacts
            } else {
                return !nutritionFacts.isEmpty ? true : false
            }
        }
    }
    var nutritionFactsIndicationUnit: [NutritionFactsPreparationStyle: NutritionEntryUnit]? = nil

    func add(fact: NutritionFactItem?, preparationStyle: NutritionFactsPreparationStyle) {
        guard let validFact = fact else { return }
        if nutritionFacts[preparationStyle] == nil {
            nutritionFacts[preparationStyle] = Set<NutritionFactItem>()
        }
        nutritionFacts[preparationStyle]?.insert(validFact)
        //nutritionFactsDict[validFact.key] = validFact
    }
    
    var possibleNutritionFactTableStyles: Set<NutritionFactsLabelStyle> {
        if let unprepared = nutritionFacts[.unprepared] {
            return NutritionFactsLabelStyle.styles(for: unprepared)
        } else if let prepared = nutritionFacts[.prepared] {
            return NutritionFactsLabelStyle.styles(for: prepared)
        }
        return []
    }
    
    // The style that best fits the nutrients
    var bestNutritionFactTableStyle: NutritionFactsLabelStyle {
        let countryBasedStyles = NutritionFactsLabelStyle.styles(for: Set(self.countriesInterpreted.list))
        var bestStyles: Set<NutritionFactsLabelStyle> = []
        if let unprepared = nutritionFacts[.unprepared] {
            bestStyles = NutritionFactsLabelStyle.styles(for: unprepared)
        } else if let prepared = nutritionFacts[.prepared] {
            bestStyles = NutritionFactsLabelStyle.styles(for: prepared)
        }
        
        let interSection = countryBasedStyles.intersection(bestStyles).first
        return interSection ?? NutritionFactsLabelStyle.current
    }
    
    var nutritionScore: [(NutritionItem, NutritionLevelQuantity)]? = nil
//
// MARK: - Supply chain variables
//
    var nutritionGrade: NutritionalScoreLevel? = nil
    var nutritionalScoreUKDecoded: NutritionalScore? = nil
    var nutritionalScoreFRDecoded: NutritionalScoreFR? = nil
    var nutritionalScoreUKCalculated: NutritionalScore? = nil
    var nutritionalScoreFRCalculated: NutritionalScoreFR? = nil

    var ecoscore: Ecoscore = .unknown
    var ecoscoreData: OFFProductEcoscoreData? = nil
    
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

    // suplied by producers
    var producerLanguage: [String:String?] = [:]
    var customerServiceLanguage: [String:String?] = [:]
    var conservationConditionsLanguage: [String:String?] = [:]
    var preparationLanguage: [String:String?] = [:]
    var warningLanguage: [String:String?] = [:]
    var otherInformationLanguage: [String:String?] = [:]

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
                    let translatedKey = OFFplists.manager.translateCountry(country, language: preferredLanguage) ?? country
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
                    newAddress.raw = manufacturingPlace.compactMap{ $0 }.joined(separator: ",")
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
        if barcode.productType != nil {
            return barcode.productType
        }
        
        if let validServer = server {
            if validServer == "opff" {
                return .petFood
            } else if validServer == "obf" {
                return .beauty
            } else if validServer == "opf" {
                return .product
            }
        }
        
        // does the main image contain info on product type?
        if let lan = primaryLanguageCode {
            return frontImages[lan]?.small?.url?.productServertype
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

//
// NOVA variables
//
    var novaGroup: String? = nil
    var novaGroupsTags: Tags = .undefined
    var novaGroupDebug: String? = nil
    var novaGroupServing: String? = nil
    var novaGroup100g: String? = nil
    
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
    
    var originsOriginal: Tags = .undefined
    var originsInterpreted: Tags = .undefined
    var originsAddress: Address? {
        get {
            switch originsOriginal {
            case .available(let origin):
                if !origin.isEmpty {
                    let newAddress = Address()
                    newAddress.raw = origin.compactMap{ $0 }.joined(separator: ",")
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
        for (_, image) in images {
            if let validTime = image.imageDate {
                let validDate = Date(timeIntervalSince1970: validTime)
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
                        translatedList.append(OFFplists.manager.translateCategory(item, language:preferredLanguage) ?? item)
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
    var categoriesHierarchyTranslated: Tags {
        get {
            switch categoriesHierarchy {
            case let .available(list):
                if !list.isEmpty {
                    var translatedList:[String] = []
                    let preferredLanguage = Locale.preferredLanguages[0]
                    for item in list {
                        translatedList.append(OFFplists.manager.translateCategory(item, language:preferredLanguage) ?? item)
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
    
    var novaEvaluation: [Int:Tags] = [:]
    var novaEvaluationTranslated: [Int:Tags] {
        var novaTranslated: [Int:Tags] = [:]
        for nova in novaEvaluation {
            switch nova.value {
            case .available(let list):
                var listTranslated : [String] = []
                for item in list {
                    let parts = item.split(separator: "/")
                    if parts.count > 0 {
                        if parts[0] == "ingredients" {
                            if let translated = OFFplists.manager.translateIngredient(String(parts[1]), language: Locale.interfaceLanguageCode) {
                                listTranslated.append(String(format: TranslatableStrings.IngredientSpecific, translated))
                            } else {
                                listTranslated.append(item)
                            }
                        } else if parts[0] == "additives" {
                            if let translated = OFFplists.manager.translateAdditive(String(parts[1]), language: Locale.interfaceLanguageCode) {
                                listTranslated.append(String(format: TranslatableStrings.AdditiveSpecific, translated))
                            } else {
                                listTranslated.append(item)
                            }
                        } else if parts[0] == "categories" {
                            if let translated = OFFplists.manager.translateCategory(String(parts[1]), language: Locale.interfaceLanguageCode) {
                                listTranslated.append(String(format: TranslatableStrings.CategorySpecific, translated))
                            } else {
                                listTranslated.append(item)
                            }
                        } else {
                            listTranslated.append(item)
                        }
                    }
                }
                novaTranslated[nova.key] = .available(listTranslated)

            default:
                novaTranslated[nova.key] = nova.value
            }
        }
        return novaTranslated
    }

    var json: JSON?
    var forestFootprint: ForestFootprint? = nil
    
    var attributeGroups: [ProductAttributeGroup]? {
        switch attributeGroupsFetchStatus {
        // start the fetch
        case .initialized:
            //fetchAttributes()
            print("Product: the attributes will not be fetched.")
        case .success(let productAttributeGroups):
            return productAttributeGroups
        default:
            break
        }
        return nil
    }
    
    private var attributeGroupsFetchStatus: AttributeGroupsFetchStatus = .initialized

    enum AttributeGroupsFetchStatus {
        // nothing is known at the moment
        case initialized
        // loading indicates that it is trying to load the product
        case loading
        // it has been retrieved
        case success([ProductAttributeGroup])
        // loading failed
        case failed(String)
    }
    
    private func fetchAttributes() {
        let request = OpenFoodFactsRequest()
        request.fetchAttributesJson(for: self.barcode, in: Locale.interfaceLanguageCode) { (completion: ProductFetchStatus) in
            let fetchResult = completion
            switch fetchResult {
            case .success(let product):
                if product.barcode.asString == self.barcode.asString,
                    let attributeGroups = product.attributeGroups {
                    self.attributeGroupsFetchStatus = .success(attributeGroups)
                }
            default:
                self.attributeGroupsFetchStatus = .failed("")
            }
        }
    }
    
// MARK: - folksonomy
    
    private var fsnmSession = URLSession.shared
    private var folksonomyTagFetchStatus: FolksonomyTagFetchStatus = .initialized
    
    public var folksonomyTags: [FSNM.Tag]? {
        // check the fetch status, so to not do a repeated fetch
        switch folksonomyTagFetchStatus {
        // start the fetch
        case .initialized:
            fetchFolksonomyTags()
            folksonomyTagFetchStatus = .loading(barcode.asString)
        case .success(let tags):
            return tags
        default:
            break
        }
        return nil
    }
    
    // do the actual retrieval of the folksonomy tags for this product
    private func fetchFolksonomyTags() {
        // Need to update the foodviewer barcode to the FSNM barcode struct
        fsnmSession.FSNMtags(with: OFFBarcode.init(barcode: barcode.asString), and: nil) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let productTags):
                    self.folksonomyTagFetchStatus = .success(productTags)
                case .failure(let error):
                    self.folksonomyTagFetchStatus = .failed(error.description)
                }
                let userInfo = [ProductPair.Notification.BarcodeKey: OFFBarcode.init(barcode: self.barcode.asString)] as [String : Any]
                DispatchQueue.main.async(execute: { () -> Void in
                    NotificationCenter.default.post(name: .ProductPairUpdated, object:nil, userInfo: userInfo)
                })
            }
        }
    }
    
    /// The FSNMTagFetchStatus describes the  retrieval status of a fsnm tags retrieval call
    enum FolksonomyTagFetchStatus {
        // nothing is known at the moment
        case initialized
        // the barcode is set, but no load is initialised
        case notLoaded(String) // (barcodeString)
        case failed(String)
        // loading indicates that it is trying to load the product
        case loading(String) // The string indicates the barcodeString
        // the product has been loaded successfully and can be set.
        case success([FSNM.Tag])
        // the product is not available on the off servers
    }

// MARK: - robotoff
    
    private func fetchRobotoffQuestions() {
        let request = OpenFoodFactsRequest()
        request.fetchRobotoffQuestionsJson(for: self.barcode, in: Locale.interfaceLanguageCode, count: nil) { (completion: OFFRobotoffQuestionFetchStatus) in
            let fetchResult = completion
            switch fetchResult {
            case .success(let questions):
                var validQuestions: [RobotoffQuestion] = []
                for question in questions {
                    if question.barcode == self.barcode.asString {
                        validQuestions.append(question)
                    }
                }
                self.robotoffQuestionsFetchStatus = .success(validQuestions)
            default:
                self.robotoffQuestionsFetchStatus = .failed("")
            }
        }
    }
    
    public var robotoffQuestions: [RobotoffQuestion]? {
        switch robotoffQuestionsFetchStatus {
        // start the fetch
        case .initialized:
            fetchRobotoffQuestions()
            robotoffQuestionsFetchStatus = .loading(barcode.asString)
        case .success(let questions):
            return questions
        default:
            break
        }
        return nil
    }
    
    public func remove(robotoff question: RobotoffQuestion) {
        switch robotoffQuestionsFetchStatus {
        case .success(var questions):
            guard let index = robotoffQuestions?.lastIndex(where: ({ $0 == question }) ) else { return }
            questions.remove(at: index)
            robotoffQuestionsFetchStatus = .success(questions)
        default:
            break
        }
        return
    }
    
    private var robotoffQuestionsFetchStatus: OFFRobotoffQuestionFetchStatus = .initialized

    /// The robotoff questions filter for a specific type
    public func robotoffQuestions(for robotoffQuestionType: RobotoffQuestionType) -> [RobotoffQuestion] {
        guard let questions = robotoffQuestions else { return [] }
        var filteredQuestions: [RobotoffQuestion] = []
        for question in questions {
            if question.field == robotoffQuestionType {
                filteredQuestions.append(question)
            }
        }
        return filteredQuestions
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
        nameLanguage = [:]
        genericNameLanguage = [:]
        ingredientsLanguage = [:]
        ingredientsTags = .undefined
        ingredientsHierarchy = .undefined
        //mainUrlThumb = nil
        //mainImageUrl = nil
        //mainImageData = nil
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
        vitamins = .undefined
        minerals = .undefined
        nucleotides = .undefined
        otherNutritionalSubstances = .undefined
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
        nutritionFacts = [:]
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
        attributeGroupsFetchStatus = .initialized
    }
    
    convenience init(with barcodeType: BarcodeType) {
        self.init()
        self.barcode = barcodeType
    }
    
    // This init is only meant to retrieve and set the attributes
    convenience init(attributesJson validProduct: OFFProductDetailed) {
        self.init()
        if let offAttributeGroups = validProduct.attribute_groups {
            var attributeGroups: [ProductAttributeGroup] = []
            for group in offAttributeGroups {
                attributeGroups.append(ProductAttributeGroup(data: group))
            }
            attributeGroupsFetchStatus = .success(attributeGroups)
        }
        
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
                        .front_photo_selected,
                        .front_photo_to_be_selected,
                        .ingredients_completed,
                        .ingredients_to_be_completed,
                        .ingredients_photo_selected,
                        .ingredients_photo_to_be_selected,
                        .nutrition_facts_completed,
                        .nutrition_facts_to_be_completed,
                        .nutrition_photo_selected,
                        .nutrition_photo_to_be_selected,
                        .packaging_completed,
                        .packaging_to_be_completed,
                        .packaging_photo_selected,
                        .packaging_photo_to_be_selected,
                        .packaging_photo_not_selected,
                        .photos_to_be_uploaded,
                        .photos_uploaded,
                        .photos_validated,
                        .photos_to_be_validated,
                        .product_name_completed,
                        .product_name_to_be_completed,
                        .quantity_completed,
                        .quantity_to_be_completed,
                        .checked,
                        .to_be_checked:
                            state.states.insert(ProductCompletion(with: currentState))
                    default:
                        break
                    }
                }
            }
        }

        func decodeNutritionalScore(_ jsonString: String?) {
            
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
                
                // is there useful info in the string?
                if (validJsonString.contains("-- energy ")) {
                    var isBeverage = false
                    var isCheese = false
                    var isFat = false
                    var energy: Int? = nil
                    var energyBeverage: Int? = nil
                    var sugars: Int? = nil
                    var sugarsBeverage: Int? = nil
                    var saturatedFats: Int? = nil
                    var saturatedFatsBeverage: Int? = nil
                    var saturatedFatRatio: Int? = nil
                    var sodium: Int? = nil
                    var sodiumBeverage: Int? = nil
                    var fiber: Int? = nil
                    var fruitVegetablesNuts: Int? = nil
                    var proteins: Int? = nil
                    var scoreUK: Int? = nil
                    var scoreFrance: Int? = nil

                    // split on --, should give 4 parts: empty, nutriments, fsa, fr
                    let dashParts = validJsonString.components(separatedBy: "-- ")
                    var offset = 0
                    if dashParts.count == 5 {
                        offset = 1
                        if dashParts[1].contains("beverages") {
                            isBeverage = true
                        } else if dashParts[1].contains("cheeses") {
                            isCheese = true
                        } else if dashParts[1].contains("fats") {
                            isFat = true
                        }
                    }
                    // find the total fsa score
                    var spaceParts2 = dashParts[2+offset].components(separatedBy: " ")
                    if let validScore = Int.init(spaceParts2[1]) {
                        scoreUK = validScore
                    }
                    
                    spaceParts2 = dashParts[3+offset].components(separatedBy: " ")
                    if let validScore = Int.init(spaceParts2[1]) {
                        scoreFrance = validScore
                    }
                    
                    if isBeverage {
                        // the french calculation for beverages uses a different table and evaluation
                        // use after the :
                        let colonParts = dashParts[1].components(separatedBy: ": ")
                        // split on +
                        let plusParts = colonParts[1].components(separatedBy: " + ")
                        // split on space to find the numbers
                        var spacePart = plusParts[0].components(separatedBy: " ")
                        // energy

                        if let validValue = Int.init(spacePart[0]) {
                            energyBeverage = validValue
                        }
                        // sat_fat
                        spacePart = plusParts[1].components(separatedBy: " ")
                        if let validValue = Int.init(spacePart[0]) {
                            saturatedFatsBeverage = validValue
                        }
                        // sugars
                        spacePart = plusParts[2].components(separatedBy: " ")
                        if let validValue = Int.init(spacePart[0]) {
                            sugarsBeverage = validValue
                        }
                        // sodium
                        spacePart = plusParts[3].components(separatedBy: " ")
                        if let validValue = Int.init(spacePart[0]) {
                            sodiumBeverage = validValue
                        }
                    }
                        // split on -,
                        let minusparts = dashParts[1+offset].components(separatedBy: " - ")
                            
                        var spacePart = minusparts[1].components(separatedBy: " ")
                        // fruits
                        if let validValue = Int.init(spacePart[2]) {
                            fruitVegetablesNuts = validValue
                        }
                            
                        // fiber
                        spacePart = minusparts[2].components(separatedBy: " ")
                        if let validValue = Int.init(spacePart[1]) {
                            fiber = validValue
                        }
                            
                        // proteins
                        spacePart = minusparts[3].components(separatedBy: " ")
                        if let validValue = Int.init(spacePart[1]) {
                            proteins = validValue
                        }
                            
                        let plusParts = minusparts[0].components(separatedBy: " + ")
                            
                        // energy
                        spacePart = plusParts[0].components(separatedBy: " ")
                        if let validValue = Int.init(spacePart[1]) {
                            energy = validValue
                        }
                            
                        // saturated fats
                        spacePart = plusParts[1].components(separatedBy: " ")
                        if let validValue = Int.init(spacePart[1]) {
                            saturatedFats = validValue
                        }
                            
                        // saturated fat ratio
                        spacePart = plusParts[2].components(separatedBy: " ")
                        if let validValue = Int.init(spacePart[1]) {
                            saturatedFatRatio = validValue
                        }
                            
                        // sugars
                        spacePart = plusParts[3].components(separatedBy: " ")
                        if let validValue = Int.init(spacePart[1]) {
                            sugars = validValue
                        }
                        
                        // sodium
                        spacePart = plusParts[4].components(separatedBy: " ")
                        if let validValue = Int.init(spacePart[1]) {
                            sodium = validValue
                        }
                    
                    nutritionalScoreUKDecoded = NutritionalScore.init(energyPoints: energy, saturatedFatPoints: saturatedFats, sugarPoints: sugars, sodiumPoints: sodium, fruitVegetablesNutsPoints: fruitVegetablesNuts, fiberPoints: fiber, proteinPoints: proteins)
                    nutritionalScoreUKDecoded?.decodedScore = scoreUK
                    
                    if isBeverage {
                        nutritionalScoreFRDecoded = NutritionalScoreFR.init(energyPoints: energyBeverage, saturatedFatPoints: saturatedFatsBeverage, saturatedFatToTotalFatRatioPoints: saturatedFatRatio, sugarPoints: sugarsBeverage, sodiumPoints: sodiumBeverage, fiberPoints: fiber, proteinPoints: proteins, fruitsVegetableNutsPoints: fruitVegetablesNuts, fruitsVegetableNutsEstimatedPoints: nil, isBeverage: isBeverage, isFat: isFat, isCheese: isCheese)
                    } else {
                        nutritionalScoreFRDecoded = NutritionalScoreFR.init(energyPoints: energy, saturatedFatPoints: saturatedFats, saturatedFatToTotalFatRatioPoints: saturatedFatRatio, sugarPoints: sugars, sodiumPoints: sodium, fiberPoints: fiber, proteinPoints: proteins, fruitsVegetableNutsPoints: fruitVegetablesNuts, fruitsVegetableNutsEstimatedPoints: nil, isBeverage: isBeverage, isFat: isFat, isCheese: isCheese)
                    }
                    nutritionalScoreFRDecoded?.decodedScore = scoreFrance
                } else if validJsonString.contains("no nutriscore for category") {
                    nutritionalScoreFRDecoded = NutritionalScoreFR.init(isAvailable: false)
                } else if validJsonString.contains("missing") {
                    nutritionalScoreFRDecoded = NutritionalScoreFR.init(isMissing: true)
                }
            }
        }
        
        
        
        func nutritionDecode(_ nutrient: Nutrient, with values: OFFProductNutrimentValues?) -> NutritionFactItem? {
            
            guard let validValues = values else { return nil }
            var nutritionItem = NutritionFactItem()
            
            nutritionItem.nutrient = nutrient
            
            // The translation of the key in the local language
            nutritionItem.itemName = OFFplists.manager.translateNutrient(nutrient.rawValue, language:Locale.preferredLanguages[0])
            
            // Try to find the default OFF unit for the current nutriment
            switch OFFplists.manager.unit(for: nutrient) {
            case .milligram, .microgram:
                nutritionItem.standardUnit = .gram
            default:
                nutritionItem.standardUnit = OFFplists.manager.unit(for: nutrient)
            }
            
            nutritionItem.standard = validValues.per100g
            nutritionItem.value = validValues.value
            nutritionItem.serving = validValues.serving
            
            // only add a fact if it has valid values
            if nutritionItem.standard != nil
                || nutritionItem.serving != nil {
                return nutritionItem
            }
            return nil
        }

        func decodeNovaString(_ string:String?, for level:String) -> [String] {
            guard let validString = string else { return [] }
            var array: [String] = []
            let components = validString.components(separatedBy: " -- ")
            for component in components {
                let part = component.components(separatedBy: " : ")
                if part.count > 1 && part[1] == level {
                    array.append(part[0])
                }
            }
            return array
        }

        func uploadDate(_ time: Double?) -> Date? {
            guard let validTime = time else { return nil }
            guard let validTimeInterval = TimeInterval(exactly: validTime) else { return nil }
            let date = Date(timeIntervalSince1970: validTimeInterval)
            return date
        }
        
        func decodeForestFootPrint(_ jsonForestFoodPrint: OFFProductForestFootPrintData?) -> ForestFootprint? {
            if let validForestFootprint = jsonForestFoodPrint {
                var forestFootprint = ForestFootprint()
                forestFootprint.footprintPerKg = validForestFootprint.footprint_per_kg
                if let validIngredients = validForestFootprint.ingredients,
                !validIngredients.isEmpty {
                    var newIngredients: [ForestFootprintIngredient] = []
                    for ingredient in validIngredients {
                        var new = ForestFootprintIngredient()
                        //new.conditions = ingredient.conditions_tags ?? []
                        new.tagID = ingredient.tag_id
                        var type = ForestFootprintIngredientType()
                        type.deforestationRisk = ingredient.type?.deforestation_risk
                        type.name = ingredient.type?.name
                        type.soyFeedFactor = ingredient.type?.soy_feed_factor
                        type.soyYield = ingredient.type?.soy_yield
                        new.type = type
                        new.matchingTagID = ingredient.matching_tag_id
                        new.tagType = ingredient.tag_type
                        new.footprintPerKg = ingredient.footprint_per_kg
                        new.percent = ingredient.percent
                        new.percentEstimate = ingredient.percent_estimate
                        new.processingFactor = ingredient.processing_factor
                        
                        newIngredients.append(new)
                    }
                    forestFootprint.ingredients = newIngredients
                }
                return forestFootprint
            }
            return nil
        }
        
        func decodeSelectedImages(imageType: ImageTypeCategory) -> [String:ProductImageSize] {
            guard let validImages = validProduct.images else { return [:] }
            var selectedImageSet: [String:ProductImageSize] = [:]
            // Loop over all normal images
            for (selectedImageKey, value) in validImages {
                // is the imageType encoded in the key?
                guard selectedImageKey.contains(imageType.description) else { continue }
                guard let validImageId = value.imgid else { continue }
                // add information on which image is a selected image for a specific language
                // only look at key that have a language component
                // parts[0] is the image type and parts[1] the languageCode
                let parts = selectedImageKey.split(separator: "_")
                guard parts.count > 1 && parts.count <= 2 else { continue }
                // look only at elements that have a language component, i.e. count == 2
                guard parts[0].contains(imageType.description) else { continue }
                    
                let languageCode = String(parts[1])
                var decodedImageType = imageType
                decodedImageType.associatedString = languageCode
                images[validImageId]?.usedIn.append(decodedImageType)

                // Is there an original image corresponding assigned to this imageType?
                var imageSet = ProductImageSize(for: barcode, and: validImageId)
                // The uploader and uploaded time are not encoded for the selected images.
                imageSet.uploader = images[validImageId]?.uploader
                imageSet.imageDate = images[validImageId]?.imageDate
                selectedImageSet[languageCode] = imageSet
            }
            return selectedImageSet
        }
        
        self.init()
        
        barcode = BarcodeType(barcodeString: validProduct.code ?? "no code", type: Preferences.manager.showProductType)

        primaryLanguageCode = validProduct.lang
        
        for languageCode in validProduct.languages_codes {
            languageCodes.append(languageCode.key)
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

        aminoAcids = Tags(list: validProduct.amino_acids_tags)
        minerals = Tags(list: validProduct.minerals_tags)
        vitamins = Tags(list: validProduct.vitamins_tags)
        nucleotides = Tags(list: validProduct.nucleotides_tags)
        otherNutritionalSubstances = Tags(list: validProduct.other_nutritional_substances_tags)

        nameLanguage = validProduct.product_names_
        ingredientsLanguage = validProduct.ingredients_texts_
        genericNameLanguage = validProduct.generic_names_
        ingredientsTags = Tags(list: validProduct.ingredients_original_tags)
        ingredientsHierarchy = Tags(list: validProduct.ingredients_hierarchy)
        
        /*
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
        
         This is not yet in the json on 30-oct-202
        if let validImageSizes = validProduct.selected_images?.packaging {

            for (key, value) in validImageSizes.display {
                if packagingImages[key] == nil {
                    packagingImages[key] = ProductImageSize()
                }
                packagingImages[key]?.display = ProductImageData(url: value)
            }

            for (key, value) in validImageSizes.thumb {
                if packagingImages[key] == nil {
                    packagingImages[key] = ProductImageSize()
                }
                packagingImages[key]?.thumb = ProductImageData(url: value)
            }

            for (key, value) in validImageSizes.small {
                if packagingImages[key] == nil {
                    packagingImages[key] = ProductImageSize()

                }
                packagingImages[key]?.small = ProductImageData(url: value)

            }
        }
 */
        // First extract the non selected images
        if let validImages = validProduct.images {
            for (key, value) in validImages {
                if !key.contains(ImageTypeCategory.front("").description)
                    && !key.contains(ImageTypeCategory.ingredients("").description)
                    && !key.contains(ImageTypeCategory.nutrition("").description)
                    && !key.contains(ImageTypeCategory.packaging("").description) {
                    let imageSet = ProductImageSize(for: barcode, and: key)
                    if images.contains(where: { $0.key == key }) {
                        images[key]?.thumb = imageSet.thumb
                        images[key]?.small = imageSet.small
                        images[key]?.display = imageSet.display
                        images[key]?.original = imageSet.original
                    } else {
                        images[key] = imageSet
                    }
                    images[key]?.uploader = value.uploader
                    images[key]?.imageDate = value.uploaded_t
                    // Whether this image is also used as selected image,
                    // will be decoded in the selected images decoder
                }
            }
        }
        
        frontImages = decodeSelectedImages(imageType: .front(""))
        ingredientsImages = decodeSelectedImages(imageType: .ingredients(""))
        nutritionImages = decodeSelectedImages(imageType: .nutrition(""))
        packagingImages = decodeSelectedImages(imageType: .packaging(""))

        /* Then extract the selected images
        if let validImages = validProduct.images {
            for (key,value) in validImages {
                if key.contains(ImageTypeCategory.front.description)
                    || !key.contains(ImageTypeCategory.ingredients.description)
                    || !key.contains(ImageTypeCategory.nutrition.description)
                    || !key.contains(ImageTypeCategory.packaging.description) {
                    // add information on which image is a selected image for a specific language
                    // only look at key that have a language component
                    // parts[0] is the image type and parts[1] the languageCode
                    let parts = key.split(separator: "_")
                    // look only at elements that have a language component, i.e. count == 2
                    if parts.count > 1 && parts.count <= 2 {
                        let languageCode = String(parts[1])
                        if parts[0].contains(ImageTypeCategory.ingredients.description) {
                            if let localKey = value.imgid {
                                if !images.contains(where: { $0.key == localKey }) {
                                    images[localKey] = ProductImageSize()
                                }
                                images[localKey]?.usedIn.append((languageCode, .ingredients))
                                
                                let imageSet = ProductImageSize(for: barcode, and: localKey)
                                
                                if ingredientsImages.contains(where: { $0.key == languageCode }) {
                                    ingredientsImages[languageCode]?.thumb = imageSet.thumb
                                    ingredientsImages[languageCode]?.small = imageSet.small
                                    ingredientsImages[languageCode]?.display = imageSet.display
                                    ingredientsImages[languageCode]?.original = imageSet.original
                                } else {
                                    ingredientsImages[languageCode] = imageSet
                                }
                                if let id = findImageID(languageCode: languageCode, imageType: ImageTypeCategory.ingredients.description) {
                                    ingredientsImages[languageCode]?.uploader = images[id]?.uploader
                                    ingredientsImages[languageCode]?.imageDate = images[id]?.imageDate
                                }
                            }
                            
                        } else if parts[0].contains(ImageTypeCategory.front.description) {
                            if let localKey = value.imgid {
                                if !images.contains(where: { $0.key == localKey }) {
                                    images[localKey] = ProductImageSize()
                                }
                                images[localKey]?.usedIn.append((languageCode, .front))
                                
                                let imageSet = ProductImageSize(for: barcode, and: localKey)
                                if frontImages.contains(where: { $0.key == languageCode }) {
                                    frontImages[languageCode]?.thumb = imageSet.thumb
                                    frontImages[languageCode]?.small = imageSet.small
                                    frontImages[languageCode]?.display = imageSet.display
                                    frontImages[languageCode]?.original = imageSet.original
                                } else {
                                    frontImages[languageCode] = imageSet
                                }
                                if let id = findImageID(languageCode: languageCode, imageType: ImageTypeCategory.front.description) {
                                    frontImages[languageCode]?.uploader = images[id]?.uploader
                                    frontImages[languageCode]?.imageDate = images[id]?.imageDate
                                }

                            }
                        } else if parts[0].contains(ImageTypeCategory.nutrition.description) {
                            if let localKey = value.imgid {
                                if !images.contains(where: { $0.key == localKey }) {
                                    images[localKey] = ProductImageSize()
                                }
                                images[localKey]?.usedIn.append((languageCode, .nutrition))
                                
                                let imageSet = ProductImageSize(for: barcode, and: localKey)
                                if nutritionImages.contains(where: { $0.key == languageCode }) {
                                    nutritionImages[languageCode]?.thumb = imageSet.thumb
                                    nutritionImages[languageCode]?.small = imageSet.small
                                    nutritionImages[languageCode]?.display = imageSet.display
                                    nutritionImages[languageCode]?.original = imageSet.original
                                } else {
                                    nutritionImages[languageCode] = imageSet
                                }
                                if let id = findImageID(languageCode: languageCode, imageType: ImageTypeCategory.nutrition.description) {
                                nutritionImages[languageCode]?.uploader = images[id]?.uploader
                                nutritionImages[languageCode]?.imageDate = images[id]?.imageDate
                                }
                            }
                            
                        } else if parts[0].contains(ImageTypeCategory.packaging.description) {
                            if let localKey = value.imgid {
                                if !images.contains(where: { $0.key == localKey }) {
                                    images[localKey] = ProductImageSize()
                                }
                                images[localKey]?.usedIn.append((languageCode, .packaging))
                                
                                let imageSet = ProductImageSize(for: barcode, and: localKey)
                                if packagingImages.contains(where: { $0.key == languageCode }) {
                                    packagingImages[languageCode]?.thumb = imageSet.thumb
                                    packagingImages[languageCode]?.small = imageSet.small
                                    packagingImages[languageCode]?.display = imageSet.display
                                    packagingImages[languageCode]?.original = imageSet.original
                                } else {
                                    packagingImages[languageCode] = imageSet
                                }
                                if let id = findImageID(languageCode: languageCode, imageType: ImageTypeCategory.packaging.description) {
                                    packagingImages[languageCode]?.uploader = images[id]?.uploader
                                    packagingImages[languageCode]?.imageDate = images[id]?.imageDate
                                }
                            }
                        }
                    }
                }
            }
        }
 */
    
        if let numberOfIngredientsFromPalmOil = validProduct.ingredients_from_palm_oil_n,
            numberOfIngredientsFromPalmOil > 0 {
            containsPalm = true
        } else {
            containsPalm = false
        }
        
        if let numberOfIngredientsThatMayBeFromPalmOil = validProduct.ingredients_that_may_be_from_palm_oil_n,
            numberOfIngredientsThatMayBeFromPalmOil > 0 {
            mightContainPalm = true
        } else {
            mightContainPalm = false
        }

        
        additivesInterpreted = Tags(list:validProduct.additives_tags)
        
        creator = validProduct.creator
        if let validCreator = creator {
            addUserRole(validCreator, role: .creator)
        }
        correctors = validProduct.correctors_tags
        correctors?.forEach({ addUserRole($0, role: .corrector) })
        informers = validProduct.informers_tags
        correctors?.forEach({ addUserRole($0, role: .informer) })
        photographers = validProduct.photographers_tags
        correctors?.forEach({ addUserRole($0, role: .photographer) })
        editors = validProduct.editors_tags
        correctors?.forEach({ addUserRole($0, role: .editor) })

        
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
        
        producerLanguage = validProduct.producer_
        customerServiceLanguage = validProduct.customer_service_
        conservationConditionsLanguage = validProduct.conservation_conditions_
        preparationLanguage = validProduct.preparation_
        warningLanguage = validProduct.warning_
        otherInformationLanguage = validProduct.other_information_

        additionDate = validProduct.created_t
        hasNutritionFacts = decodeNutritionDataAvalailable(validProduct.no_nutrition_data)
        
        servingSize = validProduct.serving_size

        var grade: NutritionalScoreLevel = .undefined
        grade.string(validProduct.nutrition_grade_fr)
        nutritionGrade = grade
        if let validEcoscore = validProduct.ecoscore_grade {
            ecoscore = Ecoscore(rawValue: "\(validEcoscore)") ?? .unknown
        }
        ecoscoreData = validProduct.ecoscore_data
        storesOriginal = Tags(string: validProduct.stores)
        storesInterpreted = Tags(list: validProduct.stores_tags)
        
        
        originsInterpreted = Tags(list: validProduct.origins_tags)
        originsOriginal = Tags(string: validProduct.origins)
        
        manufacturingPlacesInterpreted = Tags(list: validProduct.manufacturing_places_tags)
        manufacturingPlacesOriginal = Tags(string: validProduct.manufacturing_places)
        
        categoriesOriginal = Tags(string: validProduct.categories)
        categoriesHierarchy = Tags(list: validProduct.categories_hierarchy)
        categoriesInterpreted = Tags(list: validProduct.categories_tags)
        
        quantity = validProduct.quantity
        nutritionFactsIndicationUnit?[.unprepared] = decodeNutritionFactIndicationUnit(validProduct.nutrition_data_per)
        nutritionFactsIndicationUnit?[.prepared] = decodeNutritionFactIndicationUnit(validProduct.nutrition_data_prepared_per)
        
        periodAfterOpeningString = validProduct.period_after_opening
        
        expirationDateString = validProduct.expiration_date
        // This is need as the didSet of exirationDateString is not called in an init.
        expirationDate = decodeDate(expirationDateString)
        //print("FoodProduct ", name, expirationDateString, expirationDate)
        
        allergensInterpreted = Tags(list: validProduct.allergens_tags)
        allergensOriginal = Tags(string: validProduct.allergens)
        allergensHierarchy = Tags(list: validProduct.allergens_hierarchy)
        
        novaGroupsTags = Tags(list: validProduct.nova_groups_tags)
        novaGroup = validProduct.nova_group
        //print("FoodProduct:nova_group_debug", validProduct.nova_group_debug)
        novaEvaluation[0] = Tags(list:decodeNovaString(validProduct.nova_group_debug, for: "1"))
        novaEvaluation[1] = Tags(list:decodeNovaString(validProduct.nova_group_debug, for: "2"))
        novaEvaluation[2] = Tags(list:decodeNovaString(validProduct.nova_group_debug, for: "3"))
        novaEvaluation[3] = Tags(list:decodeNovaString(validProduct.nova_group_debug, for: "4"))
        
        nutritionScore = [(NutritionItem.fat,
                           NutritionLevelQuantity.value(for:validProduct.nutrient_levels?.fat)),
                          (NutritionItem.saturatedFat,
                           NutritionLevelQuantity.value(for:validProduct.nutrient_levels?.saturated_fat)),
                          (NutritionItem.sugar,
                           NutritionLevelQuantity.value(for:validProduct.nutrient_levels?.sugars)),
                          (NutritionItem.salt,
                           NutritionLevelQuantity.value(for:validProduct.nutrient_levels?.salt))]
        
        for nutrient in Nutrient.allCases {
            add(fact: nutritionDecode(nutrient, with: validProduct.nutriments?.nutriments[nutrient.rawValue]), preparationStyle: .unprepared)
            add(fact: nutritionDecode(nutrient, with: validProduct.nutriments?.preparedNutriments[nutrient.rawValue]), preparationStyle: .prepared)
        }
        
        self.forestFootprint = decodeForestFootPrint(validProduct.forest_footprint_data)
        
        
        decodeNutritionalScore(validProduct.nutrition_score_debug)
        nutritionalScoreFRDecoded = validProduct.nutriscore_data?.nutriscore
        //print("FR Decoded: ",nutritionalScoreFRDecoded?.description)
        if let unprepared = nutritionFacts[.unprepared] {
            nutritionalScoreUKCalculated = NutritionalScore.init(nutritionFacts: unprepared)
            nutritionalScoreFRCalculated = NutritionalScoreFR.init(nutritionFacts: unprepared, taxonomy: categoriesHierarchy)
        }
        //print("UK Calculated: ",nutritionalScoreUKCalculated?.description)
        // load the attribute groups
        
        // The attributes have no added value, so no need to retrieve them
        //switch attributeGroupsFetchStatus {
        //case .initialized:
        //    fetchAttributes()
        //default: break
        //}
    }
    
    init(product: FoodProduct) {
        self.barcode = product.barcode
    }
    
    func nutritionFactsContain(_ nutrient: Nutrient, nutritionFactsPreparationStyle: NutritionFactsPreparationStyle) -> Bool {
        guard let nutritionFacts = nutritionFacts[nutritionFactsPreparationStyle] else { return false }
        return nutritionFacts.contains(where: {( $0.key == nutrient.key )})
    }
    
    // If an update is successfull, the updated data can be removed
    func removedUpdatedData() {
        //barcode = BarcodeType.notSet
        nameLanguage = [:]
        genericNameLanguage = [:]
        languageCodes = []
        brandsOriginal = .undefined
        packagingOriginal = .undefined
        quantity = nil
        
        ingredientsLanguage = [:]
        tracesOriginal = .undefined
        labelsOriginal = .undefined
        
        servingSize = nil
        nutritionFacts = [:]
        hasNutritionFacts = nil

        manufacturingPlacesOriginal = .undefined
        originsOriginal = .undefined
        embCodesOriginal = .undefined
        purchasePlacesAddress = nil
        purchasePlacesOriginal = .undefined
        storesOriginal = .undefined
        countriesOriginal = .undefined
         
        categoriesOriginal = .undefined
    }
    
    // Checks if the product has any images defined
    var hasImages: Bool {
        return images.count > 0
            || nutritionImages.count > 0
            || frontImages.count > 0
            || ingredientsImages.count > 0
            || packagingImages.count > 0
    }

    // checks if the product has any fields defined
    // (looks only at editable fields)
    var isEmpty: Bool {
        return nameLanguage.isEmpty &&
        genericNameLanguage.isEmpty &&
        ingredientsLanguage.isEmpty &&
        brandsOriginal == .undefined &&
        packagingOriginal == .undefined &&
        quantity == nil &&
        tracesOriginal == .undefined &&
        labelsOriginal == .undefined &&
        manufacturingPlacesOriginal == .undefined &&
        originsOriginal == .undefined &&
        embCodesOriginal == .undefined &&
        servingSize == nil &&
        nutritionFacts.isEmpty &&
        purchasePlacesAddress == nil &&
        purchasePlacesOriginal == .undefined &&
        storesOriginal == .undefined &&
        countriesOriginal == .undefined &&
        languageCodes.isEmpty &&
        categoriesOriginal == .undefined &&
        hasNutritionFacts == nil
    }
    

    
    var regionURL: URL? {
        URL(string: OFF.webProductURLFor(barcode))
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
        if genericNameLanguage[languageCode] != nil, genericNameLanguage[languageCode]! == genericName {
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
    
    // This calculated variable is needed for the creation of a OFF json
    var asOFFProductJson: OFFProductJson {
        
        var unprepared: [String: NutritionFactItem] = [:]
        var prepared: [String: NutritionFactItem] = [:]
        
        if let valid = self.nutritionFacts[.unprepared] {
            for element in valid {
                unprepared[element.key] = element
            }
        }
        if let valid = self.nutritionFacts[.prepared] {
            for element in valid {
                prepared[element.key] = element
            }
        }

        let offNutriments = OFFProductNutriments(nutritionFactsDict: unprepared,
                                                 preparedNutritionFactsDict: prepared)
    
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
        
        return OFFProductJson(product: offProduct, status: 1, code: self.barcode.asString, status_verbose: "Restored from FoodViewer")
    }

    // End product
}

// Definition:
extension Notification.Name {
    static let MainImageSet = Notification.Name("FoodProduct.Notification.MainImageSet")
    static let IngredientsImageSet = Notification.Name("FoodProduct.Notification.IngredientsImageSet")
    static let NutritionImageSet = Notification.Name("FoodProduct.Notification.NutritionImageSet")
    static let PackagingImageSet = Notification.Name("FoodProduct.Notification.PackagingImageSet")
}

