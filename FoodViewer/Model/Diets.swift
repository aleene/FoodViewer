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
            static let Additives = "Additives"
            static let Categories = "Categories"
            static let Description = "Description"
            static let Ingredients = "Ingredients"
            static let Languages = "Languages"
            static let Labels = "Labels"
            static let Levels = "Levels"
            static let Neutral = "Neutral"
            static let Order = "Order"
            static let Other = "Other"
            static let Taxonomies = "Taxonomies"
            static let Title = "Title"
            static let Traces = "Traces"
        }
    }
    
    fileprivate struct Diet {
        var key: String // the diet key
        var languages: [Language] // the diet names in multipe languages
        var levels: [Level]
        var neutralLevel: Int?
    }
    
    fileprivate struct Language {
        var key: String
        var names: [String]
    }
    
    fileprivate struct Level {
        var key: String
        var order: Int
        var languages: [Language]
        var taxonomies: [Taxonomy]
    }
    
    fileprivate struct Taxonomy {
        var key: String
        var names: [[String]]  // the first one is the key, the others parents
    }
    
    public var count: Int? {
        checkInit()
        return all.count
    }
    
    public func name(for index:Int, in languageCode:String) -> String? {
        if let (_, name) = keyAndName(for:index, in:languageCode) {
            return name
        }
        return nil
    }
    
    public func key(for index:Int, in languageCode:String) -> String? {
        if let (key, _) = keyAndName(for:index, in:languageCode) {
            return key
        }
        return nil
    }
    
    public func name(forDietWith key:String, in languageCode:String)-> String? {
        checkInit()
        guard let validLanguages = all[key]?.languages else { return nil }
        for language in validLanguages {
            if language.key == languageCode {
                return language.names.first 
            }
        }
        return nil
    }

    public func keyAndName(for index:Int, in languageCode:String) -> (String, String)? {
        checkInit()
        guard let validCount = count else { return nil }
        guard index >= 0 else { return nil }
        guard index < validCount else { return nil }
        if let languageName = sort(on: languageCode)[index].languages.first,
            let name = languageName.names.first {
            return (sort(on: languageCode)[index].key,name)
        } else {
            return nil
        }
    }
    
    // The order is used here as identifier for the level
    public func levelName(for index:Int, and order:Int, in languageCode:String) -> String? {
        checkInit()
        guard let validCount = count else { return nil }
        guard index >= 0 else { return nil }
        guard index < validCount else { return nil }
        
        for level in sort(on: languageCode)[index].levels {
            if level.order == order {
                return levelName(for:level, in:languageCode)
            }
        }
        return nil
    }
    
    private func levelCount(for index:Int, in languageCode:String) -> Int {
        checkInit()
        guard let validCount = count else { return 0 }
        guard index >= 0 else { return 0 }
        guard index < validCount else { return 0 }
        return sort(on: languageCode)[index].levels.count
    }
    
    private func taxonomiesCount(for index:Int, and level:Int, in languageCode:String) -> Int {
        checkInit()
        guard let validCount = count else { return 0 }
        guard index >= 0 else { return 0 }
        guard index < validCount else { return 0 }
        return sort(on: languageCode)[index].levels[level].taxonomies.count
    }
    
    // provides the triggers for each taxonomy, each level in a specific diet and a language
    // [(localised level_name, [(localised taxonomy name, [localised tags])])]
    public func triggers(forDiet index:Int, in languageCode:String) -> [(String, [(String, [String])])] {
        guard count != nil else { return [] }
        var triggers: [(String, [(String, [String])])] = []
        if sort(on: languageCode)[index].levels.count > 0 {
            for level in sort(on: languageCode)[index].levels.sorted(by: { $0.order < $1.order }) {
                var result: [(String, [String])] = []
                if level.taxonomies.count > 0 {
                    for taxonomy in level.taxonomies {
                        var taxo: [String] = []
                        for name in taxonomy.names {
                            if let validTag = name.first {
                             taxo.append(taxonomy.key + "/" + validTag)
                            }
                        }
                        let taxName = taxonomyName(for:taxonomy, in:languageCode) ?? "Diets:No tax language defined"
                        result.append( (taxName, translate(taxo)) )
                    }
                    let name = levelName(for:level, in:languageCode) ?? "Diets:No level language defined"
                    triggers.append( (name, result) )
                } else {
                    triggers.append( ("No taxonomies for this level defined", []) )
                }
            }
        } else {
            triggers.append( ("No triggers for any level defined", []) )
        }
        return triggers
    }
    
    fileprivate func levelName(for level:Level, in languageCode:String) -> String? {
        for language in level.languages {
            if language.key == languageCode {
                return language.names.first
            }
        }
        return nil
    }
    
    fileprivate func taxonomyName(for taxonomy:Taxonomy, in languageCode:String) -> String? {
        if taxonomy.key == Constant.Key.Additives {
            return TranslatableStrings.Additives
        } else if taxonomy.key == Constant.Key.Categories {
            return TranslatableStrings.Categories
        } else if taxonomy.key == Constant.Key.Ingredients {
            return TranslatableStrings.Ingredients
        } else if taxonomy.key == Constant.Key.Labels {
            return TranslatableStrings.Labels
        } else if taxonomy.key == Constant.Key.Other {
            return TranslatableStrings.OtherNutritionalSubstances
        } else if taxonomy.key == Constant.Key.Traces {
            return TranslatableStrings.Traces
        }

        return nil
    }

    fileprivate var all: [String:Diet] = [:]

    fileprivate func numberOfLevels(forDietWith key:String) -> Int? {
        checkInit()
        guard let diet = all[key] else { return nil }
        return diet.levels.count
    }
    
    fileprivate func order(forDietWith key:String, and level:Int) -> Int? {
        checkInit()
        guard let diet = all[key] else { return nil }
        return diet.levels[level].order
    }
    
    public func conclusion(_ product:FoodProduct, withDietAt index:Int, in languageCode:String) -> Int? {
        let diets = sort(on: languageCode)
        return conclusion(product, forDietWith:diets[index].key)
    }
    
    public func conclusion(_ product:FoodProduct, forDietWith key:String) -> Int? {
        checkInit()
        guard let neutralLevel = all[key]?.neutralLevel else { return nil }
        var neutralIndex: Int? = nil
        var numberOfLevelsWithMatches = 0
        var lowestLevelWithAMatch: Int? = nil
        var highestLevelWithAMatch: Int? = nil
        if let numberOfLevels = numberOfLevels(forDietWith:key) {
            var matchedDiet: [(Int,[String])] = []
            for levelIndex in 0...numberOfLevels - 1 {
                if let order = order(forDietWith:key, and:levelIndex) {
                    let matchedTags = match(product, withDietWith: key, in: order)
                    matchedDiet.append((order,matchedTags))
                }
            }
            let sortedMatchedDiet : [(Int,[String])] = matchedDiet.sorted(by: { x, y in
                return x.0 < y.0 })
            for (levelIndex, (order,matches)) in sortedMatchedDiet.enumerated() {
                if matches.count > 0 {
                    if let lowest = lowestLevelWithAMatch {
                        if levelIndex < lowest {
                            lowestLevelWithAMatch = levelIndex
                        }
                    } else {
                        lowestLevelWithAMatch = levelIndex
                    }
                    if let highest = highestLevelWithAMatch {
                        if levelIndex > highest {
                            highestLevelWithAMatch = levelIndex
                        }
                    } else {
                        highestLevelWithAMatch = levelIndex
                    }
                    
                    if matches.count != 0 {
                        numberOfLevelsWithMatches += 1
                    }
                }
                if order == neutralLevel {
                    neutralIndex = levelIndex
                }
            }
            
        }
        if let validNeutralIndex = neutralIndex {
            // A high match means claimed or certified
            if highestLevelWithAMatch != nil && highestLevelWithAMatch! > validNeutralIndex {
                return highestLevelWithAMatch! - validNeutralIndex
            }
            // A low match means adverse indicators have been found
            if lowestLevelWithAMatch != nil && lowestLevelWithAMatch! < validNeutralIndex {
                return lowestLevelWithAMatch! - validNeutralIndex
            }
            // Only positive matches are found
            if highestLevelWithAMatch != nil && highestLevelWithAMatch! == validNeutralIndex {
                return highestLevelWithAMatch! - validNeutralIndex
            }
        }
        // None of the levels has a match so we assume the neutral level must be compliant
        if numberOfLevelsWithMatches == 0 {
            return 0
        }
        return nil
    }

    public func matches(_ product:FoodProduct?, in languageCode:String) -> [[(Int,[String])]] {
        guard product != nil else { return [] }
        guard count != nil else { return [] }
        var matchesPerDietPerLevel: [[(Int,[String])]] = []
        for diet in sort(on: languageCode) {
            if let numberOfLevels = numberOfLevels(forDietWith: diet.key) {
                var matchedDiet: [(Int,[String])] = []
                for levelIndex in 0...numberOfLevels - 1 {
                    if let order = order(forDietWith: diet.key, and: levelIndex) {
                        let matchedTags = match(product!, withDietWith: diet.key, in: order)
                        matchedDiet.append((order,matchedTags))
                    }
                }
                // let sortedMatchedDiet : [(Int,[String])] = filter(matchedDiet.sorted(by: { x, y in
                //    return x.0 < y.0 }))
                
            matchesPerDietPerLevel.append(translate(matchedDiet.sorted(by:
                { x, y in return x.0 < y.0
                }) ))
            }
        }
        return matchesPerDietPerLevel
    }
    
    private func translate(_ matches: [(Int,[String])]) -> [(Int,[String])] {
        var translatedMatches: [(Int,[String])] = []
        translatedMatches = matches
        for index in 0...translatedMatches.count - 1 {
            translatedMatches[index].1 = translate(translatedMatches[index].1)
        }
        return translatedMatches
    }
    
    private func translate(_ tags: [String]) -> [String] {
        var newTag: [String] = []
        for tag in tags {
            let parts = tag.split(separator: "/")
            if parts.count > 0 {
                if parts[0] == Constant.Key.Ingredients {
                    if let translated = OFFplists.manager.translateIngredient(String(parts[1]), language: Locale.interfaceLanguageCode) {
                        newTag.append(translated)
                    } else {
                        newTag.append(String(parts[1]))
                    }
                } else if parts[0] == Constant.Key.Additives {
                    if let translated = OFFplists.manager.translateAdditive(String(parts[1]), language: Locale.interfaceLanguageCode) {
                        newTag.append(translated)
                    } else {
                        newTag.append(String(parts[1]))
                    }
                } else if parts[0] == Constant.Key.Categories {
                    if let translated = OFFplists.manager.translateCategory(String(parts[1]), language: Locale.interfaceLanguageCode) {
                        newTag.append(translated)
                    } else {
                        newTag.append(String(parts[1]))
                    }
                } else if parts[0] == Constant.Key.Traces {
                    if let translated = OFFplists.manager.translateAdditive(String(parts[1]), language: Locale.interfaceLanguageCode) {
                        newTag.append(translated)
                    } else {
                        newTag.append(String(parts[1]))
                    }
                } else if parts[0] == Constant.Key.Labels {
                    if let translated = OFFplists.manager.translateGlobalLabel(String(parts[1]), language: Locale.interfaceLanguageCode) {
                        newTag.append(translated)
                    } else {
                        newTag.append(String(parts[1]))
                    }
                } else {
                    newTag.append(String(parts[1]))
                }
            }
        }
        return newTag
    }

    // Remove tags that are found on multiple levels
    private func filter(_ matches: [(Int,[String])]) -> [(Int,[String])] {
        var filteredMatches: [(Int,[String])] = []
        filteredMatches = matches
        var remove = false
        // each tag in a level should be checked against all tags in OTHER levels
        for index in 0...matches.count - 1 {
            let tags = filteredMatches[index].1
            for (_, tag) in tags.enumerated() {
                for index2 in 0...matches.count - 1 {
                    if index == index2 { continue }
                    if let present = filteredMatches[index2].1.firstIndex(of: tag) {
                        filteredMatches[index2].1.remove(at: present)
                        remove = true
                    }
                }
                if remove {
                    if let present = filteredMatches[index].1.firstIndex(of: tag) {
                        filteredMatches[index].1.remove(at: present)
                        remove = false
                    }
                    
                }
            }
        }
        return filteredMatches
    }
    
    private func match(_ product:FoodProduct, withDietWith key:String, in order:Int) -> [String] {
        var matchedTags: [String] = []
        guard let validDiet = all[key] else { return [] }
        checkInit()
        for level in validDiet.levels {
            if level.order == order {
                for taxonomy in level.taxonomies {
                    for name in taxonomy.names {
                        if taxonomy.key == Constant.Key.Categories,
                            name.count >= 0 {
                            switch product.categoriesHierarchy {
                            case .available(let tags):
                                if tags.contains(name[0]) {
                                        matchedTags.append(Constant.Key.Categories + "/" + name[0])
                                } else if name.count == 2 {
                                    matchedTags.append(Constant.Key.Categories + "/" + name[1])
                                }

                            default: break
                            }
                        }
                        if taxonomy.key == Constant.Key.Labels,
                            name.count >= 0  {
                            switch product.labelsInterpreted {
                            case .available(let tags):
                                if tags.contains(name[0]) {
                                    matchedTags.append(Constant.Key.Labels + "/" + name[0])
                                    //if name.count == 2 {
                                    //    matchedTags.append(Constant.Key.Labels + "/" + name[1])
                                    //}
                                }
                            default: break
                            }
                        }
                        if taxonomy.key == Constant.Key.Additives,
                            name.count >= 0  {
                            switch product.additivesInterpreted {
                            case .available(let tags):
                                if tags.contains(name[0]) {
                                    matchedTags.append(Constant.Key.Additives + "/" + name[0])
                                    //if name.count == 2 {
                                    //    matchedTags.append(Constant.Key.Additives + "/" + name[1])
                                    //}
                                }
                            default: break
                            }
                        }
                        if taxonomy.key == Constant.Key.Traces,
                            name.count >= 0  {
                            switch product.tracesInterpreted {
                            case .available(let tags):
                                if tags.contains(name[0]) {
                                    matchedTags.append(Constant.Key.Traces + "/" + name[0])
                                    //if name.count == 2 {
                                    //    matchedTags.append(Constant.Key.Traces + "/" + name[1])
                                    //}
                                }
                            default: break
                            }
                        }
                        
                        if taxonomy.key == Constant.Key.Ingredients,
                            name.count >= 0  {
                            switch product.ingredientsTags {
                            case .available(let tags):
                                if tags.contains(name[0]) {
                                    matchedTags.append(Constant.Key.Ingredients + "/" + name[0])
                                    //if name.count == 2 {
                                    //    matchedTags.append(Constant.Key.Ingredients + "/" + name[1])
                                    //}
                                }
                            default: break
                            }
                        }
                        if taxonomy.key == Constant.Key.Other,
                            name.count >= 0  {
                            switch product.otherNutritionalSubstances {
                            case .available(let tags):
                                if tags.contains(name[0]) {
                                    matchedTags.append(Constant.Key.Other + "/" + name[0])
                                    //if name.count == 2 {
                                    //    matchedTags.append(Constant.Key.Other + "/" + name[1])
                                    //}
                                }
                            default: break
                            }
                        }
                    }
                }
            }
        }
        return matchedTags
    }
    
    fileprivate func sort(on languageCode:String) -> [Diet] {
        checkInit()
        var sortedDiets: [Diet] = []
        for diet in all {
            let languages = diet.value.languages
            var newLanguages: [Language] = []
            for language in languages {
                if language.names.first != nil {
                    if language.key == languageCode {
                        newLanguages.append(language)
                        break
                    }
                }
            }
            sortedDiets.append(Diet(key: diet.key, languages: newLanguages, levels:diet.value.levels, neutralLevel: diet.value.neutralLevel))
        }
        return sortedDiets.sorted(by: { $0.languages.first!.names.first! < $1.languages.first!.names.first! })
    }

    fileprivate func checkInit() {
        if all.count == 0 {
            read()
        }
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
                                var neutralLevel: Int? = nil
                                for (key, value) in validDiet {
                                    if key == Constant.Key.Title {
                                        if let validLanguagesDict = value as? [String:Any] {
                                            // var dietNamesInLanguage: [String:Any] = [:]
                                            for (languageCode, value) in validLanguagesDict {
                                                var dietNames: [String] = []
                                                // is the value corresponding to the languageCode a string array?
                                                if let validDietNames = value as? [String] {
                                                    dietNames = validDietNames
                                                }
                                                languages.append(Language(key: languageCode, names: dietNames))
                                            }
                                        } else {
                                            assert(true, "Diets: Diet languages dictionary malformatted")
                                        }
                                        
                                    } else if key == Constant.Key.Description {
                                        if let validLanguagesDict = value as? [String:Any] {
                                            // var dietNamesInLanguage: [String:Any] = [:]
                                            for (languageCode, value) in validLanguagesDict {
                                                var dietNames: [String] = []
                                                // is the value corresponding to the languageCode a string array?
                                                if let validDietNames = value as? [String] {
                                                        dietNames = validDietNames
                                                }
                                                languages.append(Language(key: languageCode, names: dietNames))
                                            }
                                        } else {
                                            assert(true, "Diets: Diet languages dictionary malformatted")
                                        }

                                    } else if key == Constant.Key.Neutral {
                                        if let neutral = value as? Int {
                                            neutralLevel = neutral
                                        } else {
                                            assert(true, "Diets: Diet neutral malformatted")
                                        }

                                    } else if key == Constant.Key.Levels {
                                        if let validLevelsDict = value as? [String:Any] {
                                            // loop over all levels of the current diet
                                            for (levelKey, levelDict) in validLevelsDict {
                                                var level = Level.init(key:levelKey, order: 0, languages: [], taxonomies: [])
                                                if let validLevel = levelDict as? [String:Any] {
                                                    for (levelElementKey, levelElement) in validLevel {
                                                        if levelElementKey == Constant.Key.Order {
                                                            if let validOrder = levelElement as? Int {
                                                                level.order = validOrder
                                                            } else {
                                                                assert(true, "Diets: Order does not contain an Int")
                                                            }
                                                        } else if levelElementKey == Constant.Key.Languages {
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
                                                        } else if levelElementKey == Constant.Key.Taxonomies {
                                                            var taxonomies: [Taxonomy] = []
                                                            if let validTaxonomiesDict = levelElement as? [String:Any] {
                                                                for (taxonomyKey, taxonomyValue) in validTaxonomiesDict {
                                                                    var taxonomy = Taxonomy(key: taxonomyKey, names: [])
                                                                    if taxonomyKey == Constant.Key.Ingredients {
                                                                        if let values = taxonomyValue as? [[String]] {
                                                                            taxonomy.names = values
                                                                        }
                                                                    } else if taxonomyKey == Constant.Key.Additives {
                                                                        if let values = taxonomyValue as? [[String]] {
                                                                            taxonomy.names = values
                                                                        }
                                                                    } else if taxonomyKey == Constant.Key.Categories {
                                                                        if let values = taxonomyValue as? [[String]] {
                                                                            taxonomy.names = values
                                                                        }
                                                                    } else if taxonomyKey == Constant.Key.Labels {
                                                                        if let values = taxonomyValue as? [[String]] {
                                                                            taxonomy.names = values
                                                                        }
                                                                    } else if taxonomyKey == Constant.Key.Other {
                                                                        if let values = taxonomyValue as? [[String]] {
                                                                            taxonomy.names = values
                                                                        }
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
                                all[validKey] = Diet(key: validKey, languages: languages, levels:levels, neutralLevel: neutralLevel)
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
        all = [:]
    }
    
}
