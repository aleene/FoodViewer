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
        static let GlobalLabelsFileName = "GlobalLabels"
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
        static let NoLanguage = TranslatableStrings.NoLanguageDefined
    }

    
    lazy var OFFadditives: Set <VertexNew>? = nil
    lazy var OFFallergens: Set <VertexNew>? = nil
    lazy var OFFaminoAcids: Set <VertexNew>? = nil
    lazy var OFFcategories: Set <VertexNew>? = nil
    lazy var OFFcountries: Set <VertexNew>? = nil
    lazy var OFFglobalLabels: Set <VertexNew>? = nil
    lazy var OFFingredients: Set <VertexNew>? = nil
    lazy var OFFlanguages: Set <VertexNew>? = nil
    lazy var OFFminerals: Set <VertexNew>? = nil
    lazy var OFFnucleotides: Set <VertexNew>? = nil
    lazy var OFFnutrients: Set <VertexNew>? = nil
    lazy var OFFstates: Set <VertexNew>? = nil
    lazy var OFFotherNutritionalSubstances: Set <VertexNew>? = nil
    lazy var OFFvitamins: Set <VertexNew>? = nil
    lazy var nutrients: [(Nutrient, String, NutritionFactUnit)] = [] // tuple (nutrient enum, nutrient name in local language, default nutrient unit?)
    
    init() {
        // read all necessary plists in the background
        OFFadditives = readPlist(Constants.AdditivesFileName)
        OFFallergens = readPlist(Constants.AllergensFileName)
        OFFaminoAcids = readPlist(Constants.AminoAcidsFileName)
        OFFcategories = readPlist(Constants.CategoriesFileName)
        OFFcountries = readPlist(Constants.CountriesFileName)
        OFFglobalLabels = readPlist(Constants.GlobalLabelsFileName)
        OFFingredients = readPlist(Constants.IngredientsFileName)
        OFFlanguages = readPlist(Constants.LanguagesFileName)
        OFFminerals = readPlist(Constants.MineralsFileName)
        OFFnucleotides = readPlist(Constants.NucleotidesFileName)
        OFFnutrients = readPlist(Constants.NutrientsFileName)
        OFFotherNutritionalSubstances = readPlist(Constants.OtherNutritionalSubstancesFileName)
        OFFstates = readPlist(Constants.StatesFileName)
        OFFvitamins = readPlist(Constants.VitaminsFileName)
        nutrients = localNutrients()
        if allLanguages.count == 0 {
            allLanguages = setupAllLanguages(Locale.preferredLanguages[0])
        }
    }
    
    var allStateKeys: [String] {
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
        if index >= 0 && OFFnutrients != nil && index <= OFFlanguages!.count {
            let currentVertex = OFFnutrients![OFFnutrients!.index(OFFnutrients!.startIndex, offsetBy: index)]
            let firstSplit = key.split(separator:"-").map(String.init)
            // get the language array for the current language
            let translatedValues = currentVertex.leaves[firstSplit[0]]
            let englishValues = currentVertex.leaves["en"]
            var unit: NutritionFactUnit = .None
            if let validUnit = currentVertex.leaves["unit"] {
                if !validUnit.isEmpty {
                    if validUnit[0] == "none" {
                        // for unitless nutrition facts
                        unit = .None
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
        return .None
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
        if index >= 0 && OFFlanguages != nil && index <= OFFlanguages!.count {
            let currentVertex = OFFlanguages![OFFlanguages!.index(OFFlanguages!.startIndex, offsetBy: index)].leaves
            let values = currentVertex[key]
            return  values != nil ? values![0] : nil
        } else {
            return nil
        }
    }

    var allLanguages: [Language] = []
    
    private func setupAllLanguages(_ localeLanguage: String) -> [Language] {
        var languages: [Language] = []
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
        guard languageCode != nil else { return TextConstants.NoLanguage }
        let allLanguages: [Language] = self.allLanguages
        if let validIndex = allLanguages.firstIndex(where: { (s: Language) -> Bool in
            s.code == languageCode!
        }){
            language = allLanguages[validIndex]
        }
        
        return language != nil ? language!.name : TextConstants.NoLanguage
    }
    
    func languageCode(for languageString:String?) -> String {
        var language: Language? = nil
        guard languageString != nil else { return TextConstants.NoLanguage }
        if let validIndex = allLanguages.firstIndex(where: { (s: Language) -> Bool in
            s.name == languageString!
        }){
            language = allLanguages[validIndex]
        }
        
        return language != nil ? language!.code : TextConstants.NoLanguage
    }
//
// MARK: - Translate functions
//

    func translateAdditive(_ key: String, language:String) -> String? {
        if let taxonomy = OFFadditives {
            return translate(key, into: language, for: taxonomy)
        }
        return String(format:TextConstants.FileNotAvailable, Constants.AdditivesFileName)
    }
    
    func translateAllergen(_ key: String, language:String) -> String? {
        if let taxonomy = OFFallergens {
            return translate(key, into: language, for: taxonomy)
        }
        return String(format:TextConstants.FileNotAvailable, Constants.AllergensFileName)
    }

    func translateAminoAcid(_ key: String, language:String) -> String? {
        if let taxonomy = OFFaminoAcids {
            return translate(key, into: language, for: taxonomy)
        }
        return String(format:TextConstants.FileNotAvailable, Constants.AminoAcidsFileName)
    }
    
    func translateCategory(_ key: String, language:String) -> String? {
        if let taxonomy = OFFcategories {
            return translate(key, into: language, for: taxonomy)
        }
        return String(format:TextConstants.FileNotAvailable, Constants.CategoriesFileName)
    }

    func translateCountry(_ key: String, language:String) -> String? {
        if let taxonomy = OFFcountries {
            return translate(key, into: language, for: taxonomy)
        }
        return String(format:TextConstants.FileNotAvailable, Constants.CountriesFileName)
    }

    func translateGlobalLabel(_ key: String, language:String) -> String? {
        if let taxonomy = OFFglobalLabels {
            return translate(key, into: language, for: taxonomy)
        } else {
            return String(format:TextConstants.FileNotAvailable, Constants.GlobalLabelsFileName)
        }
    }

    func translateIngredient(_ key: String, language:String) -> String? {
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
        if let taxonomy = OFFminerals {
            return translate(key, into: language, for: taxonomy)
        }
        return String(format:TextConstants.FileNotAvailable, Constants.MineralsFileName)
    }

    func translateNucleotide(_ key: String, language:String) -> String? {
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
        if let taxonomy = OFFnutrients {
            return translate("en:" + key, into: language, for: taxonomy)
        }
        return String(format:TextConstants.FileNotAvailable, Constants.NutrientsFileName)
    }

    func translateOther(_ key: String, language:String) -> String? {
        if let taxonomy = OFFotherNutritionalSubstances {
            return translate(key, into: language, for: taxonomy)
        }
        return String(format:TextConstants.FileNotAvailable, Constants.OtherNutritionalSubstancesFileName)
    }
    
    func translateState(_ key: String, language:String) -> String? {
        if let taxonomy = OFFstates {
            return translate(key, into: language, for: taxonomy)
        }
        return String(format:TextConstants.FileNotAvailable, Constants.StatesFileName)
    }

    func translateVitamin(_ key: String, language:String) -> String? {
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
                return  values[0].capitalized
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
}

