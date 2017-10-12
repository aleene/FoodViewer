//
//  SearchTemplate.swift
//  FoodViewer
//
//  Created by arnaud on 23/09/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

//  This class contains all the product-data necesssary to perform a search on OFF

//  Note that the actual encoding of this data happens in the struct OFF

import Foundation

class SearchTemplate {
    
    private struct Constants {
        static let Include = NSLocalizedString("Include", comment: "String to indicate whether the corresponding tags shlould included in the search")
        static let Exclude = NSLocalizedString("Exclude", comment: "String to indicate whether the corresponding tags shlould exluded from the search")
    }
    
    enum SearchType {
        case simple
        case advanced
    }
    
    // This determines the kind of search we are going to submit to OFF
    var type: SearchType = .advanced
    
    var text: String? = nil
    // var barcode: BarcodeType? = nil // simple search
    // Searching for tags, also allows to specify, 
    // whether the corresponding tag should be contained in the answer or 
    // should be excluded from the answer
    // For the moment it is assumed that the Bool holds for ALL tags
    var labels: (Tags, Bool) = (.empty, true)
    var categories: (Tags, Bool) = (.empty, true)
    var brands: (Tags, Bool) = (.empty, true)
    var packaging: (Tags, Bool) = (.empty, true)
    var origins: (Tags, Bool) = (.empty, true)
    var manufacturing_places: (Tags, Bool) = (.empty, true)
    var emb_codes: (Tags, Bool) = (.empty, true)
    var purchase_places: (Tags, Bool) = (.empty, true)
    var stores: (Tags, Bool) = (.empty, true)
    var countries: (Tags, Bool) = (.empty, true)
    var additives: (Tags, Bool) = (.empty, true)
    var allergens: (Tags, Bool) = (.empty, true)
    var traces: (Tags, Bool) = (.empty, true)
    var languages: (Tags, Bool) = (.empty, true)
    
    var level: NutritionalScoreLevel? = nil
    var includeLevel: Bool = true
    
    var completion: Completion? = nil
    
    // https://world.openfoodfacts.org/cgi/search.pl?action=process&additives=with
    // https://world.openfoodfacts.org/cgi/search.pl?action=process&ingredients_from_palm_oil=with
    // https://world.openfoodfacts.org/cgi/search.pl?action=process&ingredients_from_or_that_may_be_from_palm_oil=with
    enum IngredientsInclusion {
        case with
        case without
        case indifferent
    }
    
    var ingredientsAdditives: IngredientsInclusion = .indifferent
    var ingredientsFromPalmOil: IngredientsInclusion = .indifferent
    var ingredientsThatMayBeFromPalmOil: IngredientsInclusion = .indifferent
    var ingredientsFromOrThatMayBeFromPalmOil: IngredientsInclusion = .indifferent
    
    var numberOfSearchResults: Int = 0
    
    // Nutriments
    // https://world.openfoodfacts.org/cgi/search.pl?action=process&nutriment_0=energy&nutriment_compare_0=lt&nutriment_value_0=100
    
    
    var allNutrimentsSearch: [NutrimentSearch] = []
    
    var isEmpty: Bool {
        
        return text == nil &&
            labels.0 == Tags.empty &&
            categories.0 == .empty &&
            brands.0 == .empty &&
            packaging.0 == .empty &&
            origins.0 == .empty &&
            manufacturing_places.0 == .empty &&
            emb_codes.0 == .empty &&
            purchase_places.0 == .empty &&
            stores.0 == .empty &&
            countries.0 == .empty &&
            additives.0 == .empty &&
            allergens.0 == .empty &&
            traces.0 == .empty &&
            languages.0 == .empty &&
            completion == nil &&
            level == nil &&
            allNutrimentsSearch.isEmpty
    }
    
    init() {
        
    }
    
    convenience init(for string: String, in component: OFF.SearchComponent) {
        self.init()
        setSearchPair(component, with: string)
    }
    
    private func setSearchPair(_ component: OFF.SearchComponent, with string: String) {
        // isSearchTemplate = true
        switch component {
        // case .barcode:
            // barcode = BarcodeType.init(value: string)
        case .searchText:
            text = string
        case .brand:
            brands = (Tags.init(string), true)
        case .language:
            languages = (Tags.init(string), true)
        case .category:
            categories = (Tags.init(string), true)
        case .country:
            countries = (Tags.init(string), true)
        case .label:
            labels = (Tags.init(string), true)
        case .packaging:
            packaging = (Tags.init(string), true)
        case .purchasePlace:
            purchase_places = (Tags.init(string), true)
        case .additive:
            additives = (Tags.init(string), true)
        case .trace:
            traces = (Tags.init(string), true)
        case .allergen:
            allergens = (Tags.init(string), true)
        case .producerCode:
            emb_codes = (Tags.init(string), true)
        case .manufacturingPlaces:
            manufacturing_places = (Tags.init(string), true)
        case .store:
            stores = (Tags.init(string), true)
        /*
        case .entryDates:
            additionDate = Date.init()
        case .lastEditDate:
            lastEditDates = [Date.init()]
        case .contributor:
            creator = string
            informers = [string]
            editors = [string]
            photographers = [string]
            correctors = [string]
        case .creator:
            creator = string
        case .informer:
            informers = [string]
        case .editor:
            editors = [string]
        case .photographer:
            photographers = [string]
        case .corrector:
            correctors = [string]
        case .state:
            if let validState = OFF.completion(for: string) {
                state.states.insert(validState)
            }
        */
        case .origin:
            origins = (Tags.init(string), true)
        case .nutritionGrade:
            break
        default:
            break
        }
    }
    

    func searchPairsWithArray() -> [(OFF.SearchComponent, [String], String)] {
        var pairs: [(OFF.SearchComponent, [String], String)] = []
        
        // barcode
        //if !barcode.asString().isEmpty {
        //    pairs.append((.barcode, [barcode.asString()], true))
        //}
        
        // search text
        if text != nil && !text!.isEmpty {
            pairs.append((.searchText, [text!], ""))
        }
        
        if level != nil && level! != .undefined {
            pairs.append((.nutritionGrade, [level!.rawValue], display(includeLevel)))
        }
        
        // brand
        var (validTags, shouldContain) = brands
        if !validTags.list.isEmpty {
            pairs.append((.brand, cleanChars(validTags.list), display(shouldContain) ))
        }
        
        // categories
        (validTags, shouldContain) = categories
        if !validTags.list.isEmpty {
            pairs.append((.category, cleanChars(validTags.list), display(shouldContain) ))
        }
        // producer codes
        (validTags, shouldContain) = emb_codes
        if !validTags.list.isEmpty {
            pairs.append((.producerCode, cleanChars(validTags.list), display(shouldContain) ))
        }
        // country:
        (validTags, shouldContain) = countries
        if !validTags.list.isEmpty {
            pairs.append((.country, cleanChars(validTags.list), display(shouldContain) ))
        }
        
        // label
        (validTags, shouldContain) = labels
        if !validTags.list.isEmpty {
            pairs.append((.label, cleanChars(validTags.list), display(shouldContain) ))
        }
        // language on product
        (validTags, shouldContain) = languages
        if !validTags.list.isEmpty {
            pairs.append((.language, cleanChars(validTags.list),  display(shouldContain)))
        }
        // packaging
        (validTags, shouldContain) = packaging
        if !validTags.list.isEmpty {
            pairs.append((.packaging, cleanChars(validTags.list), display(shouldContain) ))
        }
        // purchasePlace:
        (validTags, shouldContain) = purchase_places
        if !validTags.list.isEmpty {
            pairs.append((.purchasePlace, cleanChars(validTags.list),  display(shouldContain) ))
        }
        // additive
        (validTags, shouldContain) = additives
        if !validTags.list.isEmpty {
            pairs.append((.additive, cleanChars(validTags.list),  display(shouldContain) ))
        }
        // trace
        (validTags, shouldContain) = traces
        if !validTags.list.isEmpty {
            pairs.append((.trace, cleanChars(validTags.list),  display(shouldContain) ))
        }
        // allergen
        (validTags, shouldContain) = allergens
        if !validTags.list.isEmpty {
            pairs.append((.allergen, cleanChars(validTags.list),  display(shouldContain) ))
        }
        // manufacturingPlaces
        (validTags, shouldContain) = manufacturing_places
        if !validTags.list.isEmpty {
            pairs.append((.manufacturingPlaces, cleanChars(validTags.list),  display(shouldContain) ))
        }
        // store
        //if !storesOriginal.list.isEmpty {
        //    pairs.append((.store, cleanChars(storesOriginal.list), storesOriginal.state() ?? true ))
        //}
        //let formatter = DateFormatter()
        //formatter.dateFormat = "yyyy-MM-dd"
        //if let validDate = additionDate {
        //    // entryDates:
        //    let searchString = formatter.string(from: validDate as Date)
        //    pairs.append((.entryDates, [searchString], true))
        //}
        // lastEditDate:
        //if let validDates = lastEditDates {
        //    if !validDates.isEmpty {
        //        let searchString = formatter.string(from: validDates[0] as Date)
        //        pairs.append((.lastEditDate, [searchString], true))
        //    }
        //}
        
        // creator:
        //if let validCreator = creator {
        //    pairs.append((.creator, validCreator))
        //}
        // informer:
        //if let validInformers = informers {
        //    pairs.append((.informer, cleanChars(validInformers), true))
        //}
        // editor:
        //if let validEditors = editors {
        //    pairs.append((.editor, cleanChars(validEditors), true))
        //}
        // photographer:
        //if let validPhotographers = photographers {
        //    pairs.append((.photographer, cleanChars(validPhotographers), true))
        //}
        // corrector
        //if let validCorrectors = correctors {
        //    pairs.append((.corrector, cleanChars(validCorrectors), true))
        //}
        // states:
        //for item in state.states {
        //    pairs.append((.state, [OFF.searchKey(for: item)], true))
        //}
        
            
        for nutrient in allNutrimentsSearch {
            pairs.append(( .nutrient, [nutrient.name], nutrient.searchOperator.rawValue + " " + "\(nutrient.value)" + nutrient.unit.short() ))
        }
        
        return pairs
    }

        private func display(_ val: Bool) -> String {
            return val ? "(" + Constants.Include + ")" : "(" + Constants.Exclude + ")"
        }

        private func cleanChars(_ array: [String]) -> [String] {
            var newList: [String] = []
            for item in array {
                newList.append(item.replacingOccurrences(of: " ", with: "-") )
            }
            return newList
        }
        
        func searchPairs() -> [(OFF.SearchComponent, String, Bool)] {
            let searchPairs = searchPairsWithArray()
            var pairs: [(OFF.SearchComponent, String, Bool)] = []
            for pair in searchPairs {
                for item in pair.1 {
                    pairs.append((pair.0, item, true))
                }
            }
            return pairs
        }

}
