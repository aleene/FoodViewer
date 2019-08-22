//
//  Diets.swift
//  FoodViewer
//
//  Created by arnaud on 21/08/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import Foundation

class Diets {
    
    static let manager = Diets()
    
    private struct Constant {
        static let FileName = "Diets"
        static let PlistExtension = "plist"
        struct Key {
            static let Languages = "Languages"
        }
    }
    
    private struct Diet {
        var key: String // the diet key
        var languages: [Language] // the diet names in multipe languages
        var levels: [Level]
    }
    
    private struct Language {
        var key: String
        var names: [String]
    }
    
    private struct Level {
        var key: String
        var order: Int
        var languages: [Language]
        var taxonomies: [Taxonomy]
    }
    
    private struct Taxonomy {
        var key: String
        var names: [String]
    }
    
    var count: Int {
        return all.count
    }
    
    private var all: [Diet] = []
    
    func name(for index:Int, in languageCode:String) -> String? {
        guard index > 0 && index < count else { return nil }
        if let languageName = sort(on: languageCode)[index].languages.first,
            let name = languageName.names.first {
                return name
        } else {
            return nil
        }
    }
    
    //private var all: [String:Any]? = nil
    
    private func sort(on languageCode:String) -> [Diet] {
        var sortedDiets: [Diet] = []
        for diet in all {
            let languages = diet.languages
            var newLanguages: [Language] = []
            for language in languages {
                if language.names.first != nil {
                    if language.key == languageCode {
                        newLanguages.append(language)
                        break
                    }
                }
            }
            sortedDiets.append(Diet(key: diet.key, languages: newLanguages, levels:diet.levels))
        }
        return sortedDiets.sorted(by: { $0.languages.first!.names.first! < $1.languages.first!.names.first! })
    }
    
    fileprivate func read() {
        // read the data and check the correctness
        if let path = Bundle.main.path(forResource: Constant.FileName, ofType: Constant.PlistExtension) {
            if let resultDictionary = NSDictionary(contentsOfFile: path) {
                for key:Any in resultDictionary.allKeys {
                    // key is something like "en:vegan"
                    if let validKey = key as? String {
                        if let dietDict = resultDictionary.value(forKey: validKey) {
                            if let validDiet = dietDict as? [String:Any] {
                                // a valid diet has been defined
                                var languages: [Language] = []
                                var levels: [Level] = []
                                for (languagesKey, languagesValue) in validDiet {
                                    if languagesKey == Constant.Key.Languages {
                                        if let validLanguagesDict = languagesValue as? [String:Any] {
                                            // var dietNamesInLanguage: [String:Any] = [:]
                                            for (languageCode, languageCodeValue) in validLanguagesDict {
                                                var dietNames: [String] = []
                                                // is the value corresponding to the languageCode a string array?
                                                if let validDietNames = languageCodeValue as? [String] {
                                                    dietNames = validDietNames
                                                }
                                                languages.append(Language(key: languageCode, names: dietNames))
                                            }
                                        } else {
                                            assert(true, "Diets: Diet languages dictionary malformatted")
                                        }
                                    } else if languagesKey == "Levels" {
                                        if let validLevelsDict = languagesValue as? [String:Any] {
                                            // loop over all levels of the current diet
                                            for (levelKey, levelDict) in validLevelsDict {
                                                var level = Level.init(key:levelKey, order: 0, languages: [], taxonomies: [])
                                                if let validLevel = levelDict as? [String:Any] {
                                                    for (levelElementKey, levelElement) in validLevel {
                                                        if levelElementKey == "Order" {
                                                            if let validOrder = levelElement as? Int {
                                                                level.order = validOrder
                                                            } else {
                                                                assert(true, "Diets: Order does not contain an Int")
                                                            }
                                                        } else if levelElementKey == "Languages" {
                                                            if let validLanguagesDict = levelElement as? [String:Any] {
                                                                var languages: [Language] = []
                                                                for (languageCode, languageCodeValue) in validLanguagesDict {
                                                                    // is the value corresponding to the languageCode a string array?
                                                                    if let validDietNames = languageCodeValue as? [String] {
                                                                        languages.append(Language(key: languageCode, names: validDietNames))
                                                                    } else {
                                                                        assert(true, "Diet: level names not an string array")
                                                                    }
                                                                }
                                                                level.languages = languages
                                                            } else {
                                                                assert(true, "Diet: Level languages dictionary malformatted")
                                                            }
                                                        } else if levelElementKey == "Taxonomies" {
                                                            var taxonomies: [Taxonomy] = []
                                                            if let validTaxonomiesDict = levelElement as? [String:Any] {
                                                                for (taxonomyKey, taxonomyValue) in validTaxonomiesDict {
                                                                    var taxonomy = Taxonomy(key: taxonomyKey, names: [])
                                                                    if taxonomyKey == "Ingredients",
                                                                        let values = taxonomyValue as? String {
                                                                        taxonomy.names = [values]
                                                                    } else if taxonomyKey == "Additives",
                                                                        let values = taxonomyValue as? String {
                                                                        taxonomy.names = [values]
                                                                    } else if taxonomyKey == "Categories",
                                                                        let values = taxonomyValue as? String {
                                                                        taxonomy.names = [values]
                                                                    } else if taxonomyKey == "Other",
                                                                        let values = taxonomyValue as? String {
                                                                        taxonomy.names = [values]
                                                                    } else {
                                                                        assert(true, "Diet: Taxonomy with a wrong key or array")
                                                                    }
                                                                    taxonomies.append(taxonomy)
                                                                }
                                                            } else {
                                                                assert(true, "Diet: Taxonomies dictionary malformatted")
                                                            }
                                                            level.taxonomies = taxonomies
                                                        } else {
                                                            assert(true, "Diets: Levels contains a non-complient key")
                                                        }
                                                    }
                                                } else {
                                                    assert(true, "Diets: Single level dictionary malformatted")
                                                }
                                                levels.append(level)
                                            }
                                        } else {
                                            assert(true, "Diets: Diet contains a non-compliant key")
                                        }
                                    } else {
                                        assert(true, "Diets: Diet malformatted")
                                    }
                                    
                                }
                                all.append(Diet(key: validKey, languages: languages, levels:levels))
                            }
                        }
                    }
                }
            } else {
                assert(true, "Diets: File can not be read")
            }

        } else {
            assert(true, "Diets: File can not be found")
        }
    }
    
    public func flush() {
        all = []
    }
    
}
