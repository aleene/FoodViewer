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
    
    internal struct Notification {
        static let SearchTypeChangedKey = "SearchTemplate.Notification.SearchTypeChanged.Key"
    }
    
    enum SearchType {
        case simple
        case advanced
        case indifferent
    }
    
    var sortOrder: SearchSortOrder = .popularity
    
    // This determines the kind of search we are going to submit to OFF
    var type: SearchType {
        get {
            // barcode search is only supported for simple search
            if barcode != nil ||
                ingredients.hasTags ||
                creationDate != nil ||
                lastEditDate != nil {
                return .simple
            // exclude is only supported in advanced search
            } else if labels.1 == false ||
                categories.1 == false ||
                brands.1 == false ||
                packaging.1 == false ||
                origins.1 == false ||
                manufacturing_places.1 == false ||
                emb_codes.1 == false ||
                purchase_places.1 == false ||
                stores.1 == false ||
                countries.1 == false ||
                additives.1 == false ||
                allergens.1 == false ||
                traces.1 == false ||
                languages.1 == false ||
                includeLevel == false {
                return .advanced
            }
            return .indifferent
        }
    }
    
    var text: String? = nil
    
    var barcode: BarcodeType? = nil {
        willSet {
            // Will the Template change to a simple query?
            if type == .indifferent {
                NotificationCenter.default.post(name: .SearchTypeChanged, object:nil, userInfo: nil)
            }
        }
        didSet {
            // advanced queries do not support barcode search
            if type == .advanced  {
                barcode = nil
            }
        }
    }
    
    var ingredients: Tags = .empty {
        willSet {
            // Will the Template change to a simple query?
            if type == .indifferent {
                NotificationCenter.default.post(name: .SearchTypeChanged, object:nil, userInfo: nil)
            }
        }
        didSet {
            // advanced queries do not support ingredients search
            if type == .advanced  {
                ingredients = .empty
            }
        }
    }

 // simple search
    // Searching for tags, also allows to specify, 
    // whether the corresponding tag should be contained in the answer or 
    // should be excluded from the answer
    // For the moment it is assumed that the Bool holds for ALL tags
    var labels: (Tags, Bool) = (.empty, true) {
        willSet {
            // Will the Template change to a simple query?
            if type == .indifferent && newValue.1 == false {
                NotificationCenter.default.post(name: .SearchTypeChanged, object:nil, userInfo: nil)
            }
        }
        didSet {
            if type == .simple {
                labels.1 = true
            }
        }
    }
    
    var categories: (Tags, Bool) = (.empty, true) {
        willSet {
            // Will the Template change to a simple query?
            if type == .indifferent && newValue.1 == false {
                NotificationCenter.default.post(name: .SearchTypeChanged, object:nil, userInfo: nil)
            }
        }
        didSet {
            // Simple queries do not use the boolean
            if type == .simple {
                categories.1 = true
            }
        }
    }

    var brands: (Tags, Bool) = (.empty, true) {
        willSet {
            // Will the Template change to a simple query?
            if type == .indifferent && newValue.1 == false {
                NotificationCenter.default.post(name: .SearchTypeChanged, object:nil, userInfo: nil)
            }
        }
        didSet {
            if type == .simple {
                brands.1 = true
            }
        }
    }

    var packaging: (Tags, Bool) = (.empty, true) {
        willSet {
            // Will the Template change to a simple query?
            if type == .indifferent && newValue.1 == false {
                NotificationCenter.default.post(name: .SearchTypeChanged, object:nil, userInfo: nil)
            }
        }
        didSet {
            if type == .simple {
                packaging.1 = true
            }
        }
    }

    var origins: (Tags, Bool) = (.empty, true) {
        willSet {
            // Will the Template change to a simple query?
            if type == .indifferent && newValue.1 == false {
                NotificationCenter.default.post(name: .SearchTypeChanged, object:nil, userInfo: nil)
            }
        }
        didSet {
            if type == .simple {
                origins.1 = true
            }
        }
    }

    var manufacturing_places: (Tags, Bool) = (.empty, true) {
        willSet {
            // Will the Template change to a simple query?
            if type == .indifferent && newValue.1 == false {
                NotificationCenter.default.post(name: .SearchTypeChanged, object:nil, userInfo: nil)
            }
        }
        didSet {
            if type == .simple {
                manufacturing_places.1 = true
                NotificationCenter.default.post(name: .SearchTypeChanged, object:nil, userInfo: nil)
            }
        }
    }

    var emb_codes: (Tags, Bool) = (.empty, true) {
        willSet {
            // Will the Template change to a simple query?
            if type == .indifferent && newValue.1 == false {
                NotificationCenter.default.post(name: .SearchTypeChanged, object:nil, userInfo: nil)
            }
        }
        didSet {
            if type == .simple {
                emb_codes.1 = true
                NotificationCenter.default.post(name: .SearchTypeChanged, object:nil, userInfo: nil)
            }
        }
    }

    var purchase_places: (Tags, Bool) = (.empty, true) {
        willSet {
            // Will the Template change to a simple query?
            if type == .indifferent && newValue.1 == false {
                NotificationCenter.default.post(name: .SearchTypeChanged, object:nil, userInfo: nil)
            }
        }
        didSet {
            if type == .simple {
                purchase_places.1 = true
                NotificationCenter.default.post(name: .SearchTypeChanged, object:nil, userInfo: nil)
            }
        }
    }

    var stores: (Tags, Bool) = (.empty, true) {
        willSet {
            // Will the Template change to a simple query?
            if type == .indifferent && newValue.1 == false {
                NotificationCenter.default.post(name: .SearchTypeChanged, object:nil, userInfo: nil)
            }
        }
        didSet {
            if type == .simple {
                stores.1 = true
                NotificationCenter.default.post(name: .SearchTypeChanged, object:nil, userInfo: nil)
            }
        }
    }

    var countries: (Tags, Bool) = (.empty, true) {
        willSet {
            // Will the Template change to a simple query?
            if type == .indifferent && newValue.1 == false {
                NotificationCenter.default.post(name: .SearchTypeChanged, object:nil, userInfo: nil)
            }
        }
        didSet {
            if type == .simple {
                countries.1 = true
                NotificationCenter.default.post(name: .SearchTypeChanged, object:nil, userInfo: nil)
            }
        }
    }

    var additives: (Tags, Bool) = (.empty, true) {
        willSet {
            // Will the Template change to a simple query?
            if type == .indifferent && newValue.1 == false {
                NotificationCenter.default.post(name: .SearchTypeChanged, object:nil, userInfo: nil)
            }
        }
        didSet {
            if type == .simple {
                additives.1 = true
                NotificationCenter.default.post(name: .SearchTypeChanged, object:nil, userInfo: nil)
            }
        }
    }

    var allergens: (Tags, Bool) = (.empty, true) {
        willSet {
            // Will the Template change to a simple query?
            if type == .indifferent && newValue.1 == false {
                NotificationCenter.default.post(name: .SearchTypeChanged, object:nil, userInfo: nil)
            }
        }
        didSet {
            if type == .simple {
                allergens.1 = true
                NotificationCenter.default.post(name: .SearchTypeChanged, object:nil, userInfo: nil)
            }
        }
    }

    var traces: (Tags, Bool) = (.empty, true) {
        willSet {
            // Will the Template change to a simple query?
            if type == .indifferent && newValue.1 == false {
                NotificationCenter.default.post(name: .SearchTypeChanged, object:nil, userInfo: nil)
            }
        }
        didSet {
            if type == .simple {
                traces.1 = true
                NotificationCenter.default.post(name: .SearchTypeChanged, object:nil, userInfo: nil)
            }
        }
    }

    var languages: (Tags, Bool) = (.empty, true) {
        willSet {
            // Will the Template change to a simple query?
            if type == .indifferent && newValue.1 == false {
                NotificationCenter.default.post(name: .SearchTypeChanged, object:nil, userInfo: nil)
            }
        }
        didSet {
            if type == .simple {
                languages.1 = true
                NotificationCenter.default.post(name: .SearchTypeChanged, object:nil, userInfo: nil)
            }
        }
    }

    var level: NutritionalScoreLevel? = nil
    
    var includeLevel: Bool = true {
        willSet {
            // Will the Template change to a simple query?
            if type == .indifferent && newValue == false {
                NotificationCenter.default.post(name: .SearchTypeChanged, object:nil, userInfo: nil)
            }
        }
        didSet {
            if type == .simple {
                includeLevel = true
            }
        }
    }
    
    var completion: Completion? = nil
    
    // https://world.openfoodfacts.org/cgi/search.pl?action=process&additives=with
    // https://world.openfoodfacts.org/cgi/search.pl?action=process&ingredients_from_palm_oil=with
    // https://world.openfoodfacts.org/cgi/search.pl?action=process&ingredients_from_or_that_may_be_from_palm_oil=with
    enum IngredientsInclusion {
        case with
        case without
        case indifferent
    }
    
    var contributors: [Contributor] = []
    
    var ingredientsAdditives: IngredientsInclusion = .indifferent
    var ingredientsFromPalmOil: IngredientsInclusion = .indifferent
    var ingredientsThatMayBeFromPalmOil: IngredientsInclusion = .indifferent
    var ingredientsFromOrThatMayBeFromPalmOil: IngredientsInclusion = .indifferent
    
    var numberOfSearchResults: Int? = nil
    
    // Nutriments
    // https://world.openfoodfacts.org/cgi/search.pl?action=process&nutriment_0=energy&nutriment_compare_0=lt&nutriment_value_0=100
    
    
    var allNutrimentsSearch: [NutrimentSearch] = []
    
    var creationDate: Date? = nil {
        willSet {
            // Will the Template change to a simple query?
            if type == .indifferent {
                NotificationCenter.default.post(name: .SearchTypeChanged, object:nil, userInfo: nil)
            }
        }
        didSet {
            // advanced queries do not support barcode search
            if type == .advanced  {
                creationDate = nil
            }
        }
    }

    var lastEditDate: Date? = nil {
        willSet {
            // Will the Template change to a simple query?
            if type == .indifferent {
                NotificationCenter.default.post(name: .SearchTypeChanged, object:nil, userInfo: nil)
            }
        }
        didSet {
            // advanced queries do not support barcode search
            if type == .advanced  {
                lastEditDate = nil
            }
        }
    }

    // No search has been set up
    var isEmpty: Bool {
        
        return text == nil &&
            barcode == nil &&
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
            allNutrimentsSearch.isEmpty &&
            contributors.isEmpty &&
            ingredients == .empty &&
            creationDate == nil &&
            lastEditDate == nil
    }
    
    init() {
        
    }
    
    convenience init(for string: String, in component: SearchComponent) {
        self.init()
        setSearchPair(component, with: string)
    }
    
    func clear() {
        text = nil
        barcode = nil
        labels = (.empty, true)
        categories = (.empty, true)
        brands = (.empty, true)
        packaging = (.empty, true)
        origins = (.empty, true)
        manufacturing_places = (.empty, true)
        emb_codes = (.empty, true)
        purchase_places = (.empty, true)
        stores = (.empty, true)
        countries = (.empty, true)
        additives = (.empty, true)
        allergens = (.empty, true)
        traces = (.empty, true)
        languages = (.empty, true)
        completion = nil
        level = nil
        allNutrimentsSearch = []
        contributors = []
        ingredients = .empty
        creationDate = nil
        lastEditDate = nil
    }

    private func setSearchPair(_ component: SearchComponent, with string: String) {
        // isSearchTemplate = true
        switch component {
        // case .barcode: // SIMPLE search only
            // barcode = BarcodeType.init(value: string)
        case .searchText:
            text = string
        case .brand:
            brands = (Tags.init(string:string), true)
        case .language:
            languages = (Tags.init(string:string), true)
        case .category:
            categories = (Tags.init(string:string), true)
        case .country:
            countries = (Tags.init(string:string), true)
        case .label:
            labels = (Tags.init(string:string), true)
        case .packaging:
            packaging = (Tags.init(string:string), true)
        case .purchasePlace:
            purchase_places = (Tags.init(string:string), true)
        case .additive:
            additives = (Tags.init(string:string), true)
        case .trace:
            traces = (Tags.init(string:string), true)
        case .allergen:
            allergens = (Tags.init(string:string), true)
        case .producerCode:
            emb_codes = (Tags.init(string:string), true)
        case .manufacturingPlaces:
            manufacturing_places = (Tags.init(string:string), true)
        case .store:
            stores = (Tags.init(string:string), true)
        case .contributor: // For the time being I interpret contributor as creator
            contributors.append(Contributor.init(string, role: .creator))
        case .creator:
            contributors.append(Contributor.init(string, role: .creator))
        //case .informer: Not supported by OFF
        //    contributors.append(Contributor.init(string, role: .informer))
        case .editor:
            contributors.append(Contributor.init(string, role: .editor))
        //case .photographer: Not supported by OFF
        //    contributors.append(Contributor.init(string, role: .photographer))
        // case .corrector: Not supported by OFF
        //   contributors.append(Contributor.init(string, role: .corrector))
            
        case .state:
            completion = OFF.completion(for: string)
            /*

        case .entryDates: // SIMPLE search only
            creationDate = Date.in
        case .lastEditDate: // SIMPLE search only
            lastEditDates = [Date.init()]
        */
        case .origin:
            origins = (Tags.init(string:string), true)
        case .nutritionGrade:
            level = NutritionalScoreLevel.init(string)
        default:
            break
        }
    }
    

    func searchPairsWithArray() -> [(SearchComponent, [String], String)] {
        var pairs: [(SearchComponent, [String], String)] = []
        
        // barcode // SIMPLE search only
        if barcode != nil && !barcode!.asString.isEmpty {
            pairs.append((.barcode, [barcode!.fill], display(true)))
        }
        
        // search text
        if text != nil && !text!.isEmpty {
            pairs.append((.searchText, [text!], ""))
        }
        
        if !ingredients.list.isEmpty {
            pairs.append((.ingredient, cleanChars(ingredients.list), display(true )))
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
        // origins
        (validTags, shouldContain) = origins
        if !validTags.list.isEmpty {
            pairs.append((.label, cleanChars(validTags.list), display(shouldContain) ))
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
        // stores
        (validTags, shouldContain) = stores
        if !validTags.list.isEmpty {
            pairs.append((.store, cleanChars(validTags.list),  display(shouldContain) ))
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let validDate = creationDate {
            // entryDates:
            let searchString = formatter.string(from: validDate as Date)
            pairs.append((.entryDates, [searchString], display(true)))
        }
        // lastEditDate:
        if let validDate = lastEditDate {
            let searchString = formatter.string(from: validDate as Date)
            pairs.append((.lastEditDate, [searchString], display(true)))
        }
        
        // creator:
        if !contributors.isEmpty {
            for contributor in contributors {
                if contributor.isCreator {
                    pairs.append((.creator, [contributor.name], display(shouldContain) ))
                }
                if contributor.isEditor {
                    pairs.append((.editor, [contributor.name], display(shouldContain) ))
                }
            }
        }
        // states:
        if let validCompletion = completion {
            pairs.append((.state, [validCompletion.description], display(validCompletion.value) ))
        }
            
        for nutrient in allNutrimentsSearch {
            pairs.append(( .nutrient, [nutrient.name], nutrient.searchOperator.rawValue + " " + "\(nutrient.value)" + nutrient.unit.short() ))
        }
        
        return pairs
    }

        private func display(_ val: Bool) -> String {
            return val ? "(" + TranslatableStrings.Include + ")" : "(" + TranslatableStrings.Exclude + ")"
        }

        private func cleanChars(_ array: [String]) -> [String] {
            var newList: [String] = []
            for item in array {
                newList.append(item.replacingOccurrences(of: " ", with: "-") )
            }
            return newList
        }
        
        func searchPairs() -> [(SearchComponent, String, Bool)] {
            let searchPairs = searchPairsWithArray()
            var pairs: [(SearchComponent, String, Bool)] = []
            for pair in searchPairs {
                for item in pair.1 {
                    pairs.append((pair.0, item, true))
                }
            }
            return pairs
        }

}


// Notification definitions

extension Notification.Name {
    static let SearchTypeChanged = Notification.Name("SearchTemplate.Notification.SearchTypeChanged")
}
