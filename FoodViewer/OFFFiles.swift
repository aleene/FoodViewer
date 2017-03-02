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
        static let StatesFileName = "States"
        static let CountriesFileName = "Countries"
        static let GlobalLabelsFileName = "GlobalLabels"
        static let BrandsFileName = "Brands"
        static let CategoriesFileName = "Categories"
        static let NutrientsFileName = "Nutrients"
        static let LanguagesFileName = "Languages"
        static let TaxonomyKey = "Taxonomy"
        static let Language = "en"
        static let LanguageDivider = ":"
    }
    
    fileprivate struct TextConstants {
        static let FileNotAvailable = NSLocalizedString("Error: file %@ not available", comment: "Error to indicate that a file can not be read.")
    }

    
    lazy var OFFstates: Set <VertexNew>? = nil
    lazy var OFFadditives: Set <VertexNew>? = nil
    lazy var OFFallergens: Set <VertexNew>? = nil
    lazy var OFFcountries: Set <VertexNew>? = nil
    lazy var OFFglobalLabels: Set <VertexNew>? = nil
    lazy var OFFcategories: Set <VertexNew>? = nil
    lazy var OFFnutrients: Set <VertexNew>? = nil
    lazy var OFFlanguages: Set <VertexNew>? = nil
    lazy var nutrients: [(String, String, NutritionFactUnit)] = [] // tuple (nutrient key, nutrient name in local language)
    
    init() {
        // read all necessary plists in the background
        OFFstates = readPlist(Constants.StatesFileName)
        OFFadditives = readPlist(Constants.AdditivesFileName)
        OFFallergens = readPlist(Constants.AllergensFileName)
        OFFcountries = readPlist(Constants.CountriesFileName)
        OFFglobalLabels = readPlist(Constants.GlobalLabelsFileName)
        OFFcategories = readPlist(Constants.CategoriesFileName)
        OFFnutrients = readPlist(Constants.NutrientsFileName)
        OFFlanguages = readPlist(Constants.LanguagesFileName)
        nutrients = localNutrients()
    }
    
    // MARK: - Translate functions

    func translateStates(_ key: String, language:String) -> String {
        if OFFstates != nil {
            let firstSplit = language.characters.split{ $0 == "-" }.map(String.init)

            let vertex = VertexNew(key:key)
            // find the Vertex.Node with the key
            let index = OFFstates!.index(of: vertex)
            if  index != nil {
                
                let currentVertex = OFFstates![index!].leaves
                let values = currentVertex[firstSplit[0]]
                return  values != nil ? values![0] : key
            } else {
                return key
            }
        }
        return String(format:TextConstants.FileNotAvailable, Constants.StatesFileName)
    }
    
    func translateAdditives(_ key: String, language:String) -> String {
        if OFFadditives != nil {
            let firstSplit = language.characters.split{ $0 == "-" }.map(String.init)
            
            let vertex = VertexNew(key:key)
            // find the Vertex.Node with the key
            let index = OFFadditives!.index(of: vertex)
            if  index != nil {
                
                let currentVertex = OFFadditives![index!].leaves
                let values = currentVertex[firstSplit[0]]
                return  values != nil ? values![0] : key
            } else {
                return key
            }
        }
        return String(format:TextConstants.FileNotAvailable, Constants.AdditivesFileName)
    }

    func translateAllergens(_ key: String, language:String) -> String? {
        if OFFallergens != nil {
            let firstSplit = language.characters.split{ $0 == "-" }.map(String.init)
            
            let vertex = VertexNew(key:key)
            // find the Vertex.Node with the key
            let index = OFFallergens!.index(of: vertex)
            if  index != nil {
                
                let currentVertex = OFFallergens![index!].leaves
                let values = currentVertex[firstSplit[0]]
                return  values != nil ? values![0].capitalized : key
            } else {
                return nil
            }
        }
        return String(format:TextConstants.FileNotAvailable, Constants.AllergensFileName)
    }

    func translateCountries(_ key: String, language:String) -> String {
        if OFFcountries != nil {
            let firstSplit = language.characters.split{ $0 == "-" }.map(String.init)
            
            let vertex = VertexNew(key:key)
            // find the Vertex.Node with the key
            let index = OFFcountries!.index(of: vertex)
            if  index != nil {
                
                let currentVertex = OFFcountries![index!].leaves
                let values = currentVertex[firstSplit[0]]
                return  values != nil ? values![0] : key
            } else {
                // translation did not succeed
                return key
            }
        }
        return String(format:TextConstants.FileNotAvailable, Constants.CountriesFileName)
    }
    
    func translateGlobalLabels(_ key: String, language:String) -> String {
        if OFFglobalLabels != nil {
            let firstSplit = language.characters.split{ $0 == "-" }.map(String.init)
            
            let vertex = VertexNew(key:key)
            // find the Vertex.Node with the key
            let index = OFFglobalLabels!.index(of: vertex)
            if  index != nil {
                
                let currentVertex = OFFglobalLabels![index!].leaves
                let values = currentVertex[firstSplit[0]]
                return  values != nil ? values![0] : key
            } else {
                return key
            }
        } else {
            return String(format:TextConstants.FileNotAvailable, Constants.GlobalLabelsFileName)
        }
    }
    
    func translateCategories(_ key: String, language:String) -> String {
        
        return translate(OFFcategories, file: Constants.CategoriesFileName, key: key, language: language)
    }
    
    func translateNutrients(_ key: String, language:String) -> String {
        // remark that the key has been extended with a language for in order to be consistent with the other taxonomy keys.
        return translate(OFFnutrients, file: Constants.NutrientsFileName, key: "en:" + key, language: language)
    }
    
    func translateNutrients(extendedKey: String, language:String) -> String {
        // the extendedKey includes the language prefix such as en:
        return translate(OFFnutrients, file: Constants.NutrientsFileName, key: extendedKey, language: language)
    }


    func translateLanguage(_ key: String, language:String) -> String {
        return translate(OFFlanguages, file: Constants.LanguagesFileName, key: key, language: language)
    }
    
    fileprivate func translate(_ taxonomy: Set <VertexNew>?, file: String, key: String, language:String) -> String {
        if taxonomy != nil {
            let firstSplit = language.characters.split{ $0 == "-" }.map(String.init)
            
            let vertex = VertexNew(key:key)
            // find the Vertex.Node with the key
            let index = taxonomy!.index(of: vertex)
            if  index != nil {
                
                let currentVertex = taxonomy![index!].leaves
                let values = currentVertex[firstSplit[0]]
                return  values != nil ? values![0] : key
            } else {
                return key
            }
        } else {
            return String(format:TextConstants.FileNotAvailable, file)
        }
    }

    func language(atIndex index: Int, languageCode key: String) -> String? {
        if index >= 0 && OFFlanguages != nil && index <= OFFlanguages!.count {
            let currentVertex = OFFlanguages![OFFlanguages!.index(OFFlanguages!.startIndex, offsetBy: index)].leaves
            let values = currentVertex[key]
            return  values != nil ? values![0] : nil
        } else {
            return nil
        }
    }
    
    
    // Setup the nutrients to be used in the local language
    
    private func localNutrients() -> [(String, String, NutritionFactUnit)] {
        var nutrients: [(String, String, NutritionFactUnit)] = []
        if let nutrientVerteces = OFFnutrients {
            for (index,_) in nutrientVerteces.enumerated() {
                let nutrientTuple = nutrientText(at:index, languageCode:Locale.preferredLanguages[0])
                if nutrientTuple != nil {
                    nutrients.append(nutrientTuple!)
                }
            }
        }
        // sort the nutrients alphabetically
        nutrients = nutrients.sorted { $0.1 < $1.1 }
        return nutrients
    }

    func nutrientText(at index: Int, languageCode key: String) -> (String, String, NutritionFactUnit)? {
        if index >= 0 && OFFnutrients != nil && index <= OFFlanguages!.count {
            let currentVertex = OFFnutrients![OFFnutrients!.index(OFFnutrients!.startIndex, offsetBy: index)]
            let firstSplit = key.characters.split{ $0 == "-" }.map(String.init)
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
                return englishValues != nil ? (currentVertex.key, englishValues![0], unit) : (key, currentVertex.key, unit )
            } else {
                // return the first value of the translation array
                return  !translatedValues!.isEmpty ? (currentVertex.key, translatedValues![0], unit) : (key, NSLocalizedString("No translation", comment: "Text in a pickerView, when no translated text is available"), unit )
            }
        } else {
            return nil
        }
    }

    func nutrientVertex(atIndex index: Int) -> VertexNew? {
        if index >= 0 && OFFnutrients != nil && index <= OFFlanguages!.count {
            return OFFnutrients![OFFnutrients!.index(OFFnutrients!.startIndex, offsetBy: index)]
        } else {
            return nil
        }
    }

    func allLanguages(_ localeLanguage: String) -> [Language] {
        var languages: [Language] = []
        guard OFFlanguages != nil else { return languages }
        let firstSplit = localeLanguage.characters.split{ $0 == "-" }.map(String.init)

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
        languages.sort(by: { (s1: Language, s2: Language) -> Bool in return s1.name < s2.name } )
        return languages
    }
    
// MARK: - Read functions
    
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

