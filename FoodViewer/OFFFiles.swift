//
//  ViewController.swift
//  TaxonomyParser
//
//  Created by arnaud on 11/03/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

/*
    Understanding the OFF taxonomy mark up.
- Definition section are delimited by empty lines (\n). Each definition section defines a Vertex().
- A definition section can start with a "<" (smaller then sign), then this section defines a child.
- The ordering of the definition section is random. This implies that processing them in order might produce children Vertexes without a father Vertex.
- There are sections that do not define a Vertex. Lines in these blocks start with words like "synonyms", "stopwords"

*/
import Foundation

class OFFplists {

    // This class is implemented as a singleton
    // It is only needed by OpenFoodFactRequests.
    // An instance could be loaded for each request
    // A singleton limits however the number of file loads
    static let manager = OFFplists()
    
    fileprivate struct Constants {
        static let OpenFoodFactsExtension = "off"
        static let PlistExtension = "plist"
        static let AllergensFileName = "Allergens"
        static let AdditivesFileName = "Additives"
        static let AminoAcidsFileName = "Amino_acids"
        static let BrandsFileName = "Brands"
        static let CategoriesFileName = "Categories"
        static let CountriesFileName = "Countries"
        static let GlobalLabelsFileName = "Labels"
        static let IngredientsFileName = "Ingredients"
        // The OFF taxonomy is not good for the app.
        // The plist needs several edits:
        // - add the language iso with the two letter code
        // - remove language synonyms (not needed)
        // - capitalize languages
        static let LanguagesFileName = "Languages"
        static let MineralsFileName = "Minerals"
        static let NucleotidesFileName = "Nucleotides"
        // The OFF Nutriments taxonomy is not good for the app.
        // Remove synonyms
        // Capitalize
        // chech en:fiber, en:carbohydrates, en:cocoa (minimum)
        // add units
        static let NutrientsFileName = "Nutrients"
        static let OtherNutritionalSubstancesFileName = "Other_nutritional_substances"
        static let StatesFileName = "States"
        static let VitaminsFileName = "Vitamins"
        static let TaxonomyKey = "Taxonomy"
        static let Language = "en"
        static let LanguageDivider = ":"
    }
    
    fileprivate struct TextConstants {
        static let FileNotAvailable = "Error: file %@ not available"
    }

    
    private var OFFadditives: Set <VertexNew>? = nil
    
    public var OFFallergens: Set <VertexNew>? = nil
    private var OFFaminoAcids: Set <VertexNew>? = nil
    private var OFFcategories: Set <VertexNew>? = nil
    private var OFFcountries: Set <VertexNew>? = nil
    private var OFFglobalLabels: Set <VertexNew>? = nil
    private var OFFingredients: Set <VertexNew>? = nil
    private var OFFlanguages: Set <VertexNew>? = nil
    private var OFFminerals: Set <VertexNew>? = nil
    private var OFFnucleotides: Set <VertexNew>? = nil
    private var OFFnutrients: Set <VertexNew>? = nil
    private var OFFstates: Set <VertexNew>? = nil
    private var OFFotherNutritionalSubstances: Set <VertexNew>? = nil
    private var OFFvitamins: Set <VertexNew>? = nil
    
    // tuple (nutrient enum, nutrient name in local language, default nutrient unit?)
    public var nutrients: [(Nutrient, String, NutritionFactUnit)] {
        return localNutrients()
    }
    
    init() {
    }
    
    public var allStateKeys: [String] {
        guard OFFstates != nil else { return [] }
        var stateKeys: [String] = []
        for state in OFFstates! {
            let currentVertex = state.leaves
            let values = currentVertex["en"]
            stateKeys.append(values![0])
        }
        return stateKeys
    }
    
//
// MARK: - Nutrient functions
//
    func nutrientText(at index: Int, languageCode key: String) -> (Nutrient, String, NutritionFactUnit)? {
        if OFFlanguages == nil {
            OFFlanguages = readPlist(Constants.LanguagesFileName)
        }
        if OFFnutrients == nil {
            OFFnutrients = readPlist(Constants.NutrientsFileName)
        }
        if index >= 0 && OFFnutrients != nil && index <= OFFlanguages!.count {
            let currentVertex = OFFnutrients![OFFnutrients!.index(OFFnutrients!.startIndex, offsetBy: index)]
            let firstSplit = key.split(separator:"-").map(String.init)
            // get the language array for the current language
            let translatedValues = currentVertex.leaves[firstSplit[0]]
            let englishValues = currentVertex.leaves["en"]
            var unit: NutritionFactUnit = .none
            if let validUnit = currentVertex.leaves["unit"] {
                if !validUnit.isEmpty {
                    if validUnit[0] == "none" {
                        // for unitless nutrition facts
                        unit = .none
                    } else {
                        unit = NutritionFactUnit(validUnit[0])
                    }
                }
            }
            if translatedValues == nil {
                return englishValues != nil ? (Nutrient.value(for:currentVertex.key), englishValues![0], unit) : (Nutrient.value(for:key), currentVertex.key, unit )
            } else {
                // return the first value of the translation array
                let x =  !translatedValues!.isEmpty ? (Nutrient.value(for:currentVertex.key), translatedValues![0], unit) : (Nutrient.value(for:key), TranslatableStrings.NoTranslation, unit )
                return x
            }
        } else {
            return nil
        }
    }
    
    private func localNutrients() -> [(Nutrient, String, NutritionFactUnit)] {
        var nutrients: [(Nutrient, String, NutritionFactUnit)] = []
        if OFFnutrients == nil {
            OFFnutrients = readPlist(Constants.NutrientsFileName)
        }
        if let nutrientVerteces = OFFnutrients {
            for (index,_) in nutrientVerteces.enumerated() {
                let nutrientTuple = nutrientText(at:index, languageCode:Locale.preferredLanguages[0])
                if let validTuple = nutrientTuple {
                    switch validTuple.0 {
                    case .undefined:
                        break
                    default:
                        nutrients.append(validTuple)
                    }
                }
            }
        }
        // sort the nutrients alphabetically
        nutrients = nutrients.sorted { $0.1 < $1.1 }
        return nutrients
    }

    // function to find the unit for a specific nutrient
    func unit(for nutrient: Nutrient) -> NutritionFactUnit {
        if OFFnutrients == nil {
            OFFnutrients = readPlist(Constants.NutrientsFileName)
        }
        // find nutrient
        if let nutrientVerteces = OFFnutrients {
            for vertex in nutrientVerteces {
                if vertex.key == "en:" + nutrient.key {
                    if let validUnit = vertex.leaves["unit"] {
                        if !validUnit.isEmpty {
                            return NutritionFactUnit(validUnit[0])
                        }
                    }
                }
            }
        }
        return .none
    }
    /*
    func nutrientVertex(atIndex index: Int) -> VertexNew? {
        if index >= 0 && OFFnutrients != nil && index <= OFFlanguages!.count {
            return OFFnutrients![OFFnutrients!.index(OFFnutrients!.startIndex, offsetBy: index)]
        } else {
            return nil
        }
    }
     */
//
// MARK: - Language functions
//
    
    func language(atIndex index: Int, languageCode key: String) -> String? {
        if OFFlanguages == nil {
            OFFlanguages = readPlist(Constants.LanguagesFileName)
        }
        if index >= 0 && OFFlanguages != nil && index <= OFFlanguages!.count {
            let currentVertex = OFFlanguages![OFFlanguages!.index(OFFlanguages!.startIndex, offsetBy: index)].leaves
            let values = currentVertex[key]
            return  values != nil ? values![0] : nil
        } else {
            return nil
        }
    }

    public var allLanguages: [Language] {
        return setupAllLanguages(Locale.preferredLanguages[0])
    }
    
    private func setupAllLanguages(_ localeLanguage: String) -> [Language] {
        var languages: [Language] = []
        if OFFlanguages == nil {
            OFFlanguages = readPlist(Constants.LanguagesFileName)
        }
        guard OFFlanguages != nil else { return languages }
        let firstSplit = localeLanguage.split(separator:"-").map(String.init)

        // loop over all verteces and fill the languages array
        for vertex in OFFlanguages! {
            var language = Language()
            if let validValues = vertex.leaves["iso"] {
                language.code = validValues[0]
            }

            let values = vertex.leaves[firstSplit[0]]
            
            language.name = values != nil ? values![0] : localeLanguage
            languages.append(language)
        }
        if languages.count > 1 {
            languages.sort(by: { (s1: Language, s2: Language) -> Bool in return s1.name < s2.name } )
        }
        return languages
    }
    
    func languageName(for languageCode:String?) -> String {
        var language: Language? = nil
        guard languageCode != nil else { return TranslatableStrings.NoLanguageDefined }
        let allLanguages: [Language] = self.allLanguages
        if let validIndex = allLanguages.firstIndex(where: { (s: Language) -> Bool in
            s.code == languageCode!
        }){
            language = allLanguages[validIndex]
        }
        
        return language != nil ? language!.name : TranslatableStrings.NoLanguageDefined
    }
    
    func languageCode(for languageString:String?) -> String {
        var language: Language? = nil
        guard languageString != nil else { return TranslatableStrings.NoLanguageDefined }
        if let validIndex = allLanguages.firstIndex(where: { (s: Language) -> Bool in
            s.name == languageString!
        }){
            language = allLanguages[validIndex]
        }
        
        return language != nil ? language!.code : TranslatableStrings.NoLanguageDefined
    }
//
// MARK: - Country functions
//
    func country(atIndex index: Int, languageCode key: String) -> String? {
        if OFFcountries == nil {
            OFFcountries = readPlist(Constants.CountriesFileName)
        }
        if index >= 0 && OFFcountries != nil && index <= OFFcountries!.count {
            let currentVertex = OFFcountries![OFFcountries!.index(OFFcountries!.startIndex, offsetBy: index)].leaves
            let values = currentVertex[key]
               return  values != nil ? values![0] : nil
        } else {
            return nil
        }
    }

    public var allCountries: [Language] {
        return setupAllCountries(Locale.preferredLanguages[0])
    }

    private func setupAllCountries(_ localeLanguage: String) -> [Language] {
        var countries: [Language] = []
        if OFFcountries == nil {
            OFFcountries = readPlist(Constants.CountriesFileName)
        }
        guard OFFcountries != nil else { return countries }
        let firstSplit = localeLanguage.split(separator:"-").map(String.init)

        // loop over all verteces and fill the languages array
        for vertex in OFFcountries! {
            var country = Language()

            let values = vertex.leaves[firstSplit[0]]
                
            country.code = vertex.key
            country.name = values != nil ? values![0] : vertex.key
            countries.append(country)
        }
        if countries.count > 1 {
            countries.sort(by: { (s1: Language, s2: Language) -> Bool in return s1.name < s2.name } )
        }
        return countries
    }
        
    func countryName(for languageCode:String?) -> String {
        var country: Language? = nil
        guard languageCode != nil else { return TranslatableStrings.NoLanguageDefined }
        let allCountries: [Language] = self.allLanguages
        if let validIndex = allCountries.firstIndex(where: { (s: Language) -> Bool in
            s.code == languageCode!
        }){
            country = allCountries[validIndex]
        }
        return country != nil ? country!.name : TranslatableStrings.NoCountryDefined
    }
//
// MARK: - Category functions
//
    func category(atIndex index: Int, languageCode key: String) -> String? {
        if OFFcategories == nil {
            OFFcategories = readPlist(Constants.CategoriesFileName)
        }
        if index >= 0 && OFFcategories != nil && index <= OFFcategories!.count {
            let currentVertex = OFFcategories![OFFcategories!.index(OFFcategories!.startIndex, offsetBy: index)].leaves
            let values = currentVertex[key]
            return  values != nil ? values![0] : nil
        } else {
            return nil
        }
    }

    public var allCategories: [Language] {
        return setupAllCategories(Locale.preferredLanguages[0])
    }

    private func setupAllCategories(_ localeLanguage: String) -> [Language] {
        var categories: [Language] = []
        if OFFcategories == nil {
            OFFcategories = readPlist(Constants.CategoriesFileName)
        }
        guard OFFcategories != nil else { return categories }
        let firstSplit = localeLanguage.split(separator:"-").map(String.init)

        // loop over all verteces and fill the languages array
        for vertex in OFFcategories! {
            var category = Language()

            let values = vertex.leaves[firstSplit[0]]
                      
            category.code = vertex.key
            category.name = values != nil ? values![0] : vertex.key
            categories.append(category)
        }
        if categories.count > 1 {
            categories.sort(by: { (s1: Language, s2: Language) -> Bool in return s1.name < s2.name } )
        }
        return categories
    }
              
    func categoryName(for languageCode:String?) -> String {
        var category: Language? = nil
        guard languageCode != nil else { return TranslatableStrings.NoLanguageDefined }
        let allCategories: [Language] = self.allLanguages
        if let validIndex = allCategories.firstIndex(where: { (s: Language) -> Bool in
            s.code == languageCode!
        }){
            category = allCategories[validIndex]
        }
        return category != nil ? category!.name : TranslatableStrings.NoCategoryDefined
    }
//
// MARK: - Allergen functions
//
    func allergen(atIndex index: Int, languageCode key: String) -> String? {
        if OFFallergens == nil {
            OFFallergens = readPlist(Constants.AllergensFileName)
        }
        if index >= 0 && OFFallergens != nil && index <= OFFallergens!.count {
            let currentVertex = OFFallergens![OFFallergens!.index(OFFallergens!.startIndex, offsetBy: index)].leaves
            let values = currentVertex[key]
                return  values != nil ? values![0] : nil
        } else {
            return nil
        }
    }

    public var allAllergens: [Language] {
        return setupAllAllergens(Locale.preferredLanguages[0])
    }

    private func setupAllAllergens(_ localeLanguage: String) -> [Language] {
        var allergens: [Language] = []
        if OFFallergens == nil {
            OFFallergens = readPlist(Constants.LanguagesFileName)
        }
        guard OFFallergens != nil else { return allergens }
        let firstSplit = localeLanguage.split(separator:"-").map(String.init)

        // loop over all verteces and fill the languages array
        for vertex in OFFallergens! {
            var allergen = Language()
            let values = vertex.leaves[firstSplit[0]]
                allergen.code = vertex.key
                allergen.name = values != nil ? values![0] : vertex.key
                allergens.append(allergen)
        }
        if allergens.count > 1 {
            allergens.sort(by: { (s1: Language, s2: Language) -> Bool in return s1.name < s2.name } )
        }
        return allergens
    }
            
    func allergenName(for languageCode:String?) -> String {
        var allergen: Language? = nil
        guard languageCode != nil else { return TranslatableStrings.NoLanguageDefined }
        let allAllergens: [Language] = self.allLanguages
        if let validIndex = allAllergens.firstIndex(where: { (s: Language) -> Bool in
                s.code == languageCode!
        }){
            allergen = allAllergens[validIndex]
        }
        return allergen != nil ? allergen!.name : TranslatableStrings.NoTraceDefined
    }

//
// MARK: - Translate functions
//

    func translateAdditive(_ key: String, language:String) -> String? {
        if OFFadditives == nil {
            OFFadditives = readPlist(Constants.AdditivesFileName)
        }
        if let taxonomy = OFFadditives {
            return translate(key, into: language, for: taxonomy)
        }
        return String(format:TextConstants.FileNotAvailable, Constants.AdditivesFileName)
    }
    
    func translateAllergen(_ key: String, language:String) -> String? {
        if OFFallergens == nil {
            OFFallergens = readPlist(Constants.AllergensFileName)
        }
        if let taxonomy = OFFallergens {
            return translate(key, into: language, for: taxonomy)
        }
        return String(format:TextConstants.FileNotAvailable, Constants.AllergensFileName)
    }

    func translateAminoAcid(_ key: String, language:String) -> String? {
        if OFFaminoAcids == nil {
            OFFaminoAcids = readPlist(Constants.AminoAcidsFileName)
        }
        if let taxonomy = OFFaminoAcids {
            return translate(key, into: language, for: taxonomy)
        }
        return String(format:TextConstants.FileNotAvailable, Constants.AminoAcidsFileName)
    }
    
    func translateCategory(_ key: String, language:String) -> String? {
        if OFFcategories == nil {
            OFFcategories = readPlist(Constants.CategoriesFileName)
        }
        if let taxonomy = OFFcategories {
            return translate(key, into: language, for: taxonomy)
        }
        return String(format:TextConstants.FileNotAvailable, Constants.CategoriesFileName)
    }

    func translateCountry(_ key: String, language:String) -> String? {
        if OFFcountries == nil {
            OFFcountries = readPlist(Constants.CountriesFileName)
        }
        if let taxonomy = OFFcountries {
            return translate(key, into: language, for: taxonomy)
        }
        return String(format:TextConstants.FileNotAvailable, Constants.CountriesFileName)
    }

    func translateGlobalLabel(_ key: String, language:String) -> String? {
        if OFFglobalLabels == nil {
            OFFglobalLabels = readPlist(Constants.GlobalLabelsFileName)
        }
        if let taxonomy = OFFglobalLabels {
            return translate(key, into: language, for: taxonomy)
        } else {
            return String(format:TextConstants.FileNotAvailable, Constants.GlobalLabelsFileName)
        }
    }

    func translateIngredient(_ key: String, language:String) -> String? {
        if OFFingredients == nil {
            OFFingredients = readPlist(Constants.IngredientsFileName)
        }
        if let taxonomy = OFFingredients {
            return translate(key, into: language, for: taxonomy)
        }
        return String(format:TextConstants.FileNotAvailable, Constants.IngredientsFileName)
    }
    
    func translateLanguage(_ key: String, language:String) -> String? {
        if let taxonomy = OFFlanguages {
            return translate(key, into: language, for: taxonomy)
        }
        return String(format:TextConstants.FileNotAvailable, Constants.LanguagesFileName)
    }

    func translateMineral(_ key: String, language:String) -> String? {
        if OFFminerals == nil {
            OFFminerals = readPlist(Constants.MineralsFileName)
        }
        if let taxonomy = OFFminerals {
            return translate(key, into: language, for: taxonomy)
        }
        return String(format:TextConstants.FileNotAvailable, Constants.MineralsFileName)
    }

    func translateNucleotide(_ key: String, language:String) -> String? {
        if OFFnucleotides == nil {
            OFFnucleotides = readPlist(Constants.NucleotidesFileName)
        }
        if let taxonomy = OFFnucleotides {
            return translate(key, into: language, for: taxonomy)
        }
        return String(format:TextConstants.FileNotAvailable, Constants.NucleotidesFileName)
    }
    
    func translateNutrient(nutrient: Nutrient, language:String) -> String {
        return translateNutrient(nutrient.key, language: language) ?? nutrient.key
    }

    func translateNutrient(_ key: String, language:String) -> String? {
        // remark that the key has been extended with a language for in order to be consistent with the other taxonomy keys.
        if OFFnutrients == nil {
            OFFnutrients = readPlist(Constants.NutrientsFileName)
        }
        if let taxonomy = OFFnutrients {
            return translate("en:" + key, into: language, for: taxonomy)
        }
        return String(format:TextConstants.FileNotAvailable, Constants.NutrientsFileName)
    }

    func translateOther(_ key: String, language:String) -> String? {
        if OFFotherNutritionalSubstances == nil {
            OFFotherNutritionalSubstances = readPlist(Constants.OtherNutritionalSubstancesFileName)
        }
        if let taxonomy = OFFotherNutritionalSubstances {
            return translate(key, into: language, for: taxonomy)
        }
        return String(format:TextConstants.FileNotAvailable, Constants.OtherNutritionalSubstancesFileName)
    }
    
    func translateState(_ key: String, language:String) -> String? {
        if OFFstates == nil {
            OFFstates = readPlist(Constants.StatesFileName)
        }
        if let taxonomy = OFFstates {
            return translate(key, into: language, for: taxonomy)
        }
        return String(format:TextConstants.FileNotAvailable, Constants.StatesFileName)
    }

    func translateVitamin(_ key: String, language:String) -> String? {
        if OFFvitamins == nil {
            OFFvitamins = readPlist(Constants.VitaminsFileName)
        }
        guard let taxonomy = OFFvitamins else {
            return String(format:TextConstants.FileNotAvailable, Constants.VitaminsFileName)
        }
        return translate(key, into: language, for: taxonomy)
    }

    private func translate(_ key: String, into language:String, for taxonomy:Set<VertexNew>) -> String? {
        let firstSplit = language.split(separator:"-").map(String.init)[0]
        // find the Vertex.Node with the key
        if let index = taxonomy.firstIndex(of: VertexNew(key:key)) {
            let currentVertex = taxonomy[index].leaves
            if let values = currentVertex[firstSplit] {
                return  values[0] //.capitalized
            }
        }
        return nil
    }
    
//
// MARK: - Read functions
//
    fileprivate func readPlist(_ fileName: String) -> Set <VertexNew>? {
        // Copy the file from the Bundle and write it to the Device:
        if let path = Bundle.main.path(forResource: fileName, ofType: Constants.PlistExtension) {

            //let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
            //let documentsDirectory = paths.objectAtIndex(0) as! NSString
            //let path = documentsDirectory.stringByAppendingPathComponent(fileName + "." + Constants.PlistExtension)
            let resultDictionary = NSDictionary(contentsOfFile: path)
            // print("Saved plist file is --> \(resultDictionary?.description)")
            var verteces = Set <VertexNew>()
        
            if let result = resultDictionary {
                var vertex = VertexNew()
                for (key, value) in result {
                    let newKey = key as! String
                    let dict = Dictionary(dictionaryLiteral: (newKey, value))
                    vertex = vertex.decodeDict(dict)
                    verteces.insert(vertex)
                }
                return verteces
            }
        }
        return nil
    }
    
    public func flush() {
        print("OFFFiles: flushing")
        OFFadditives = nil
        OFFallergens = nil
        OFFaminoAcids = nil
        OFFcategories = nil
        OFFcountries = nil
        OFFglobalLabels = nil
        OFFingredients = nil
        OFFlanguages = nil
        OFFminerals = nil
        OFFnucleotides = nil
        OFFnutrients = nil
        OFFotherNutritionalSubstances = nil
        OFFstates = nil
        OFFvitamins = nil
    }
}

