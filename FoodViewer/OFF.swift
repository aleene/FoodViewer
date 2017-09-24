  //
//  OFF.swift
//  FoodViewer
//
//  Created by arnaud on 20/12/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

// JSON keys

public struct OFF {
    
    public struct URL {
        // structure of the url is:
        // "https://static.openfoodfacts.org/images/products/40111490/ingredients_en.11.400.jpg"
        //
        public struct ImageType {
            static let Front = "front"
            static let Ingredients = "ingredients"
            static let Nutrition = "nutrition"
        }
        public struct ImageSize {
            static let Thumb = ".100"
            static let Small = ".200"
            static let Display = ".400"
            static let Original = ""
        }
        public struct Divider {
            static let Slash = "/"
            static let Dot = "."
            static let Equal = "="
        }
        public struct PartNumber {
            static let Barcode = 5
        }
        
        static let Scheme = "http://"
        static let Prefix = "http://world."
        static let TopDomain = ".org/"
        static let AdvancedSearch = "cgi/search.pl?action=process"
        static let EnglishProduct = "en:product/"
        static let Postfix = ".org/api/v0/product/"
        static let JSONExtension = ".json"
        static let JSONSearchExtension = "&json=1"
        static let SearchPage = "&page="
        static let JPGextension = ".jpg"
        static let Images = "images/products/"
        static let SearchTagType = "&tagtype_"
        static let SearchTagContains = "&tag_contains_"
        static let SearchTagValue = "&tag_"
        static let SearchTerms = "&search_terms="
    }
    
    public enum Server: String {
        case food = "openfoodfacts"
        case beauty = "openbeautyfacts"
        case petFood = "openpetfoodfacts"
    }
    
    public enum ImageSize: String {
        case thumb = "100"
        case medium = "200"
        case large = "400"
        case original = "original"
    }
    

    // The strings are used in the URL's of the search query, so we look for the right thing
    public enum SearchComponent: String {
        case barcode = "code"
        case searchText = "searchText"
        case brand = "brands"
        case category = "categories"
        case country = "countries"
        case label = "labels"
        case language = "language"
        case packaging = "packaging"
        case origin = "origins"
        case purchasePlace = "purchase_places"
        case additive = "additives"
        case trace = "traces"
        case allergen = "allergens"
        case producerCode = "emb_codes"
        case manufacturingPlaces = "manufacturing-place"
        case store = "stores"
        case entryDates = "entry-dates"
        case lastEditDate = "last-edit-date"
        case contributor = "contributor"
        case creator = "creator"
        case informer = "informer"
        case editor = "editor"
        case photographer = "photographer"
        case corrector = "corrector"
        case state = "states"
        case nutrionGrade = "nutrition_grades"
    }
    
    static func description(for component: SearchComponent) -> String {
        switch component {
        case .barcode:
            return "barcode"
        case .searchText:
            return "search text"
        case .brand:
            return "brand"
        case .category:
            return "category"
        case .country:
            return "country"
        case .label:
            return "label"
        case .language:
            return "language"
        case .packaging:
            return "packaging"
        case .origin:
            return "origin"
        case .purchasePlace:
            return "purchase-place"
        case .additive:
            return "additive"
        case .trace:
            return "trace"
        case .allergen:
            return "allergen"
        case .producerCode:
            return "packager-code"
        case .manufacturingPlaces:
            return "manufacturing-place"
        case .store:
            return "store"
        case .entryDates:
            return "entry-dates"
        case .lastEditDate:
            return "last-edit-date"
        case .contributor:
            return "contributor"
        case .creator:
            return "creator"
        case .informer:
            return "informer"
        case .editor:
            return "editor"
        case .photographer:
            return "photographer"
        case .corrector:
            return "corrector"
        case .state:
            return "state"
        case .nutrionGrade:
            return "nutrition grade"
        }
    }

    // The base strings which represent the various states on OFF
    public static func string(for completion: Completion) -> String {
        switch completion.category {
        case .productName: // in JSON and search
            return "product-name"
        case .brands:
            return "brands" // in JSON and search
        case .quantity:
            return "quantity" // in JSON and search
        case .packaging:
            return "packaging" // in JSON and search
        case .ingredients:
            return "ingredients" // in JSON and search
        case .categories:
            return "categories" // in JSON and search
        case .expirationDate:
            return "expiration-date" // in JSON and search
        case .nutritionFacts:
            return "nutrition-facts" // in JSON and search
        case .photosUploaded:
            return "photos-uploaded" // in JSON and search
        case .photosValidated:
            return "photos-validated" // in JSON and search
        }
    }

    // The value strings needed for searching a status
    public static func searchKey(for completion:Completion) -> String {
        var test = ""
        switch completion.category {
        case .photosUploaded:
            test = completion.value ? string(for:completion) : "photos-to-be-uploaded"
        case .photosValidated:
            test = completion.value ? string(for:completion) : "photos-to-be-validated"
        default:
            test = string(for:completion) + ( completion.value ? "-completed" : "-to-be-completed" )
        }
        return test
    }

    // The strings used to encode the status values in the product JSON
    // These are also the keys in the taxonomy
    public static func JSONkey(for completion:Completion) -> String {
        return "en:" + searchKey(for:completion)
    }
    
    // Convert the key values found in the JSON to a Completion
    public static func JSONcompletion(for string: String) -> Completion? {
        // remove the language component
        let elements = string.characters.split{$0 == ":"}.map(String.init)
        if elements.count > 1 {
            return completion(for:elements[1])
        }
        return nil
    }

    
    // Converts the status searchKey back to a Completion object
    public static func completion(for string: String) -> Completion? {
        
        if string == searchKey(for: Completion.init(.productName, isCompleted:true)) {
            return Completion.init(.productName, isCompleted:true)
        } else if string == searchKey(for: Completion.init(.productName, isCompleted:false)) {
            return Completion.init(.productName, isCompleted:false)
            
        } else if string == searchKey(for: Completion.init(.brands, isCompleted:true)) {
            return Completion.init(.brands, isCompleted:true)
        } else if string == searchKey(for: Completion.init(.brands, isCompleted:false)) {
            return Completion.init(.brands, isCompleted:false)
            
        } else if string == searchKey(for: Completion.init(.quantity, isCompleted:true)) {
            return Completion.init(.quantity, isCompleted:true)
        } else if string == searchKey(for: Completion.init(.quantity, isCompleted:false)) {
            return Completion.init(.quantity, isCompleted:false)
            
        } else if string == searchKey(for: Completion.init(.quantity, isCompleted:true)) {
            return Completion.init(.quantity, isCompleted:true)
        } else if string == searchKey(for: Completion.init(.quantity, isCompleted:false)) {
            return Completion.init(.quantity, isCompleted:false)
            
        } else if string == searchKey(for: Completion.init(.packaging, isCompleted:true)) {
            return Completion.init(.packaging, isCompleted:true)
        } else if string == searchKey(for: Completion.init(.packaging, isCompleted:false)) {
            return Completion.init(.packaging, isCompleted:false)
            
        } else if string == searchKey(for: Completion.init(.ingredients, isCompleted:true)) {
            return Completion.init(.ingredients, isCompleted:true)
        } else if string == searchKey(for: Completion.init(.ingredients, isCompleted:false)) {
            return Completion.init(.ingredients, isCompleted:false)
            
        } else if string == searchKey(for: Completion.init(.categories, isCompleted:true)) {
            return Completion.init(.categories, isCompleted:true)
        } else if string == searchKey(for: Completion.init(.categories, isCompleted:false)) {
            return Completion.init(.categories, isCompleted:false)
            
        } else if string == searchKey(for: Completion.init(.expirationDate, isCompleted:true)) {
            return Completion.init(.expirationDate, isCompleted:true)
        } else if string == searchKey(for: Completion.init(.expirationDate, isCompleted:false)) {
            return Completion.init(.expirationDate, isCompleted:false)
            
        } else if string == searchKey(for: Completion.init(.nutritionFacts, isCompleted:true)) {
            return Completion.init(.nutritionFacts, isCompleted:true)
        } else if string == searchKey(for: .init(.nutritionFacts, isCompleted:false)) {
            return Completion.init(.nutritionFacts, isCompleted:false)
        } else if string == searchKey(for: Completion.init(.photosUploaded, isCompleted:true)) {
            return Completion.init(.photosUploaded, isCompleted:true)
        } else if string == searchKey(for: Completion.init(.photosUploaded, isCompleted:false)) {
            return Completion.init(.photosUploaded, isCompleted:false)
            
        } else if string == searchKey(for: Completion.init(.photosValidated, isCompleted:true)) {
            return Completion.init(.photosValidated, isCompleted:true)
        } else if string == searchKey(for: Completion.init(.photosValidated, isCompleted:false)) {
            return Completion.init(.photosValidated, isCompleted:false)
        }
        return nil
    }

    static func fetchString(for barcode: BarcodeType, with productType: ProductType) -> String {
        var fetchUrlString = URL.Prefix
        // add the right server
        fetchUrlString += productType.rawValue
        fetchUrlString += URL.Postfix
        fetchUrlString += barcode.asString() + URL.JSONExtension
        return fetchUrlString
    }
    
    /*
    static func searchString(with pairs: [(SearchComponent, String)], on page: Int ) -> String {
        guard !pairs.isEmpty else { return "" }
        
        // let region = Bundle.main.preferredLocalizations[0] as NSString
        var urlString = OFF.URL.Prefix
        // use the currrent product type
        urlString += server(for:Preferences.manager.showProductType)
        urlString += URL.TopDomain
        for pair in pairs {
            urlString += pair.0.rawValue
            urlString += "/"
            urlString += pair.1
            urlString += "/"
        }
        urlString += "\(page)"
        urlString += URL.JSONExtension
        return urlString
    }
 
    static func advancedSearchString(with pairs: [(SearchComponent, String, Bool)], on page: Int ) -> String {
        // https://world.openfoodfacts.org/cgi/search.pl?search_terms=banania&search_simple=1&action=process&json=1
        // https://world.openfoodfacts.org/cgi/search.pl?action=process&tagtype_0=brands&tag_contains_0=contains&tag_0=Coca
        
        guard !pairs.isEmpty else { return "" }
        
        // let region = Bundle.main.preferredLocalizations[0] as NSString
        var urlString = OFF.URL.Prefix
        // use the currrent product type
        urlString += server(for:Preferences.manager.showProductType)
        urlString += URL.TopDomain
        urlString += URL.AdvancedSearch
        for (index,pair) in pairs.enumerated() {
            switch pair.0 {
            case .additive, .allergen, .brand, .category, .country, .label, .manufacturingPlaces, .origin, .nutrionGrade, .packaging, .state, .store, .trace:
                urlString += URL.SearchTagType
                urlString += "\(index)"
                urlString += URL.Divider.Equal
                urlString += pair.0.rawValue
                
                urlString += URL.SearchTagContains
                urlString += "\(index)"
                urlString += URL.Divider.Equal
                
                urlString += pair.2 ? "contains" : "does_not_contain"
                
                urlString += URL.SearchTagValue
                urlString += "\(index)"
                urlString += URL.Divider.Equal
                urlString += pair.1
            case .searchText:
                urlString += URL.SearchTerms
                urlString += pair.1
            default:
                return ""
            }
        }
        urlString += URL.SearchPage + "\(page)"
        urlString += URL.JSONSearchExtension
        return urlString
    }
     */

    
    static func advancedSearchString(for template: SearchTemplate, on page: Int ) -> String {
        // https://world.openfoodfacts.org/cgi/search.pl?search_terms=banania&search_simple=1&action=process&json=1
        // https://world.openfoodfacts.org/cgi/search.pl?action=process&tagtype_0=brands&tag_contains_0=contains&tag_0=Coca
        
        var urlString = OFF.URL.Prefix
        // use the currrent product type
        urlString += server(for:Preferences.manager.showProductType)
        urlString += URL.TopDomain
        urlString += URL.AdvancedSearch
        
        if let validText = template.text {
            urlString += URL.SearchTerms
            urlString += validText
        }
        
        var search_tag_index = 0
        
        urlString += addSearchTag(template.labels, in: OFF.SearchComponent.label, index: &search_tag_index) ?? ""
        urlString += addSearchTag(template.brands, in: OFF.SearchComponent.brand, index: &search_tag_index) ?? ""
        urlString += addSearchTag(template.categories, in: OFF.SearchComponent.category, index: &search_tag_index) ?? ""
        urlString += addSearchTag(template.packaging, in: OFF.SearchComponent.packaging, index: &search_tag_index) ?? ""
        urlString += addSearchTag(template.origins, in: OFF.SearchComponent.origin, index: &search_tag_index) ?? ""
        urlString += addSearchTag(template.manufacturing_places, in: OFF.SearchComponent.manufacturingPlaces, index: &search_tag_index) ?? ""
        urlString += addSearchTag(template.emb_codes, in: OFF.SearchComponent.producerCode, index: &search_tag_index) ?? ""
        urlString += addSearchTag(template.purchase_places, in: OFF.SearchComponent.purchasePlace, index: &search_tag_index) ?? ""
        urlString += addSearchTag(template.stores, in: OFF.SearchComponent.store, index: &search_tag_index) ?? ""
        urlString += addSearchTag(template.countries, in: OFF.SearchComponent.country, index: &search_tag_index) ?? ""
        urlString += addSearchTag(template.additives, in: OFF.SearchComponent.additive, index: &search_tag_index) ?? ""
        urlString += addSearchTag(template.allergens, in: OFF.SearchComponent.allergen, index: &search_tag_index) ?? ""
        urlString += addSearchTag(template.traces, in: OFF.SearchComponent.trace, index: &search_tag_index) ?? ""
      
        urlString += URL.SearchPage + "\(page)"
        urlString += URL.JSONSearchExtension
        return urlString
    }
    
    static private func addSearchTag(_ pair: (Tags, Bool)?, in component:OFF.SearchComponent, index: inout Int) -> String? {
        if let (tags, shouldContain) = pair {
            if !tags.list.isEmpty {
                var urlString = ""
                for item in tags.list {
                    urlString += URL.SearchTagType
                    urlString += "\(index)"
                    urlString += URL.Divider.Equal
                    urlString += component.rawValue
                    
                    urlString += URL.SearchTagContains
                    urlString += "\(index)"
                    urlString += URL.Divider.Equal
                    
                    urlString += shouldContain ? "contains" : "does_not_contain"
                    
                    urlString += URL.SearchTagValue
                    urlString += "\(index)"
                    urlString += URL.Divider.Equal
                    urlString += item
                    index += 1
                }
                return urlString
            }
        }
        return nil
    }

    static func webProductURLFor(_ barcode: BarcodeType) -> String {
        let region = Bundle.main.preferredLocalizations[0] as NSString
        var urlString = OFF.URL.Scheme
        urlString += "\(region)."
        urlString += server(for:barcode.productType() ?? .food)
        urlString += OFF.URL.TopDomain
        urlString += OFF.URL.EnglishProduct
        urlString += barcode.asString()
        urlString += "/"
        return urlString
    }
    
    static func imageURLFor(_ barcode: BarcodeType) -> String {
        let region = Bundle.main.preferredLocalizations[0] as NSString
        var urlString = OFF.URL.Scheme
        urlString += "\(region)."
        urlString += server(for:barcode.productType() ?? .food)
        urlString += OFF.URL.TopDomain
        urlString += OFF.URL.Images
        if let str = imageURLComponentFor(barcode.asString()) {
            urlString += str
        }
        urlString += "/"
        return urlString
    }
    
    // https://world.openfoodfacts.org/images/products/803/409/462/0006/3.100.jpg
    
    static func imageURLFor(_ barcode: BarcodeType, with id:String, size:ImageSizeCategory) -> String {
        let region = Bundle.main.preferredLocalizations[0] as NSString
        var urlString = OFF.URL.Scheme
        urlString += "\(region)."
        urlString += server(for:barcode.productType() ?? .food)
        urlString += OFF.URL.TopDomain
        urlString += OFF.URL.Images
        if let str = imageURLComponentFor(barcode.asString()) {
            urlString += str
        }
        urlString += "/"
        urlString += id
        switch size {
        case .thumb:
            urlString += OFF.URL.ImageSize.Thumb
        case .small:
            urlString += OFF.URL.ImageSize.Small
        case .large:
            urlString += OFF.URL.ImageSize.Display
        case .original:
            urlString += OFF.URL.ImageSize.Original
        default:
            assert(false, "OFF.imageURLFor(_:with:size:)")
        }
        urlString += OFF.URL.JPGextension
        return urlString
    }

    static func imageURLComponentFor(_ barcode: String) -> String? {
        if barcode.characters.count == 8 {
            // Lidl product
            return barcode
        } else if barcode.characters.count == 13 {
            let part1 = barcode.index(barcode.startIndex, offsetBy: 0)...barcode.index(barcode.startIndex, offsetBy: 2)
            let part2 = barcode.index(barcode.startIndex, offsetBy: 3)...barcode.index(barcode.startIndex, offsetBy: 5)
            let part3 = barcode.index(barcode.startIndex, offsetBy: 6)...barcode.index(barcode.startIndex, offsetBy: 8)
            let part4 = barcode.index(barcode.startIndex, offsetBy: 9)...barcode.index(barcode.startIndex, offsetBy: 12)
//
            return barcode[part1] + OFF.URL.Divider.Slash +
                barcode[part2] + OFF.URL.Divider.Slash +
                barcode[part3] + OFF.URL.Divider.Slash  +
                barcode[part4]
        } else if barcode.characters.count == 11 {
            // US products
            let part1 = barcode.index(barcode.startIndex, offsetBy: 0)...barcode.index(barcode.startIndex, offsetBy: 2)
            let part2 = barcode.index(barcode.startIndex, offsetBy: 3)...barcode.index(barcode.startIndex, offsetBy: 5)
            let part3 = barcode.index(barcode.startIndex, offsetBy: 6)...barcode.index(barcode.startIndex, offsetBy: 8)
            let part4 = barcode.index(barcode.startIndex, offsetBy: 9)...barcode.index(barcode.startIndex, offsetBy: 10)
            //
            return barcode[part1] + OFF.URL.Divider.Slash +
                barcode[part2] + OFF.URL.Divider.Slash +
                barcode[part3] + OFF.URL.Divider.Slash  +
                barcode[part4]
        }
        print("OFF.imageURLFor : barcode can not be translated to url-string")
        return nil
    }

    
    static func server(for productType: ProductType) -> String {
        switch productType {
        case .food:
            return OFF.Server.food.rawValue
        case .petFood:
            return OFF.Server.petFood.rawValue
        case .beauty:
            return OFF.Server.beauty.rawValue
        }
    }

}


struct OFFReadAPIkeysJSON {
    static let StatusKey = "status"
    static let StatusVerboseKey = "status_verbose"
    static let ProductKey = "product"
    static let CodeKey = "code"
    static let LastEditDatesTagsKey = "last_edit_dates_tags"
    static let LabelsHierarchyKey = "labels_hierarchy"
    static let ImageFrontSmallUrlKey = "image_front_small_url"
    static let IIdKey = "_id"
    static let LabelsDebugTagsKey = "labels_debug_tags"
    static let CategoriesHierarchyKey = "categories_hierarchy"
    static let PnnsGroups1Key = "pnns_groups_1"
    static let StatesTagsKey = "states_tags"
    static let CheckersTagsKey = "checkers_tags"
    static let LabelsTagsKey = "labels_tags"
    static let ImageSmallUrlKey = "image_small_url"
    static let ImagesKey = "images"
    static let ProductCodeKey = "code"
    static let AdditivesTagsNKey = "additives_tags_n"
    static let TracesTagsKey = "traces_tags"
    static let LangKey = "lang"
    static let DebugParamSortedLangsKey = "debug_param_sorted_langs"
    static let LanguagesHierarchy = "languages_hierarchy"
    static let PhotographersKey = "photographers"
    static let GenericNameKey = "generic_name"
    static let IngredientsThatMayBeFromPalmOilTagsKey = "ingredients_that_may_be_from_palm_oil_tags"
    static let AdditivesPrevNKey = "additives_prev_n"
    static let KeywordsKey = "_keywords"
    static let RevKey = "rev"
    static let EditorsKey = "editors"
    static let InterfaceVersionCreatedKey = "interface_version_created"
    static let EmbCodesKey = "emb_codes"
    static let MaxImgidKey = "max_imgid"
    static let AdditivesTagsKey = "additives_tags"
    static let EmbCodesOrigKey = "emb_codes_orig"
    static let InformersTagsKey = "informers_tags"
    static let NutrientLevelsTagsKey = "nutrient_levels_tags"
    static let PhotographersTagsKey = "photographers_tags"
    static let AdditivesNKey = "additives_n"
    static let PnnsGroups2TagsKey = "pnns_groups_2_tags"
    static let UnknownNutrientsTagsKey = "unknown_nutrients_tags"
    static let CategoriesPrevTagsKey = "categories_prev_tags"
    static let PackagingTagsKey = "packaging_tags"
    static let ManufacturingPlacesKey = "manufacturing_places"
    static let LinkKey = "link"
    static let IngredientsNKey = "ingredients_n"
    static let NutrimentsKey = "nutriments"
    static let SelectedImagesKey = "selected_images"
    static let FrontImageKey = "front"
    static let NutritionImageKey = "nutrition"
    static let IngredientsImageKey = "ingredients"
    static let DisplayKey = "display"
    static let SmallKey = "small"
    static let ThumbKey = "thumb"
    
    static let SodiumKey = "sodium"
    static let SaltKey = "salt"
    static let SugarsKey = "sugars"
    static let EnergyKey = "energy"
    static let ProteinsKey = "proteins"
    static let CaseinKey = "casein"
    static let SerumProteinsKey = "serum-proteins"
    static let NucleotidesKey = "nucleotides"
    static let CarbohydratesKey = "carbohydrates"
    static let SucroseKey = "sucrose"
    static let GlucoseKey = "glucose"
    static let FructoseKey = "fructose"
    static let LactoseKey = "lactose"
    static let MaltoseKey = "maltose"
    static let MaltodextrinsKey = "maltodextrins"
    static let StarchKey = "starch"
    static let PolyolsKey = "polyols"
    static let FatKey = "fat"
    static let SaturatedFatKey = "saturated-fat"
    static let ButyricAcidKey = "butyric-acid"
    static let CaproicAcidKey = "caproic-acid"
    static let CaprylicAcidKey = "caprylic-acid"
    static let CapricAcidKey = "capric-acid"
    static let LauricAcidKey = "lauric-acid"
    static let MyristicAcidKey = "myristic-acid"
    static let PalmiticAcidKey = "palmitic-acid"
    static let StearicAcidKey = "stearic-acid"
    static let ArachidicAcidKey = "arachidic-acid"
    static let BehenicAcidKey = "behenic-acid"
    static let LignocericAcidKey = "lignoceric-acid"
    static let CeroticAcidKey = "cerotic-acid"
    static let MontanicAcidKey = "montanic-acid"
    static let MelissicAcidKey = "melissic-acid"
    static let MonounsaturatedFatKey = "monounsaturated-fat"
    static let PolyunsaturatedFatKey = "polyunsaturated-fat"
    static let Omega3FatKey = "omega-3-fat"
    static let AlphaLinolenicAcidKey = "alpha-linolenic-acid"
    static let EicosapentaenoicAcidKey = "eicosapentaenoic-acid"
    static let DocosahexaenoicAcidKey = "docosahexaenoic-acid"
    static let Omega6FatKey = "omega-6-fat"
    static let LinoleicAcidKey = "linoleic-acid"
    static let ArachidonicAcidKey = "arachidonic-acid"
    static let GammaLinolenicAcidKey = "gamma-linolenic-acid"
    static let DihomoGammaLinolenicAcidKey = "dihomo-gamma-linolenic-acid"
    static let Omega9FatKey = "omega-9-fat"
    static let VoleicAcidKey = "voleic-acid"
    static let ElaidicAcidKey = "elaidic-acid"
    static let GondoicAcidKey = "gondoic-acid"
    static let MeadAcidKey = "mead-acid"
    static let ErucicAcidKey = "erucic-acid"
    static let NervonicAcidKey = "nervonic-acid"
    static let TransFatKey = "trans-fat"
    static let CholesterolKey = "cholesterol"
    static let FiberKey = "fiber"
    static let AlcoholKey = "alcohol"
    static let VitaminAKey = "vitamin-a"
    static let VitaminDKey = "vitamin-d"
    static let VitaminEKey = "vitamin-e"
    static let VitaminKKey = "vitamin-k"
    static let VitaminCKey = "vitamin-c"
    static let VitaminB1Key = "vitamin-b1"
    static let VitaminB2Key = "vitamin-b2"
    static let VitaminPPKey = "vitamin-pp"
    static let VitaminB6Key = "vitamin-b6"
    static let VitaminB9Key = "vitamin-b9"
    static let VitaminB12Key = "vitamin-b12"
    static let BiotinKey = "biotin"
    static let PantothenicAcidKey = "pantothenic-acid"
    static let SilicaKey = "silica"
    static let BicarbonateKey = "bicarbonate"
    static let PotassiumKey = "potassium"
    static let ChlorideKey = "chloride"
    static let CalciumKey = "calcium"
    static let PhosphorusKey = "phosphorus"
    static let IronKey = "iron"
    static let MagnesiumKey = "magnesium"
    static let ZincKey = "zinc"
    static let CopperKey = "copper"
    static let ManganeseKey = "manganese"
    static let FluorideKey = "fluoride"
    static let SeleniumKey = "selenium"
    static let ChromiumKey = "chromium"
    static let MolybdenumKey = "molybdenum"
    static let IodineKey = "iodine"
    static let CaffeineKey = "caffeine"
    static let TaurineKey = "taurine"
    static let PhKey = "ph"
    static let CacaoKey = "cocoa"
    static let NutritionScoreFr100gKey = "nutrition-score-fr_100g"
    static let NutritionScoreFrKey = "nutrition-score-fr"
    static let NutritionScoreUk100gKey = "nutrition-score-uk_100g"
    static let CountriesTagsKey = "countries_tags"
    static let IngredientsFromPalmOilTagsKey = "ingredients_from_palm_oil_tags"
    static let EmbCodesTagsKey = "emb_codes_tags"
    static let BrandsTagsKey = "brands_tags"
    static let PurchasePlacesKey = "purchase_places"
    static let PnnsGroups2Key = "pnns_groups_2"
    static let CountriesHierarchyKey = "countries_hierarchy"
    static let TracesKey = "traces"
    static let AdditivesOldTagsKey = "additives_old_tags"
    static let ImageNutritionUrlKey = "image_nutrition_url"
    static let CategoriesKey = "categories"
    static let IngredientsTextDebugKey = "ingredients_text_debug"
    static let IngredientsTextKey = "ingredients_text"
    static let EditorsTagsKey = "editors_tags"
    static let LabelsPrevTagsKey = "labels_prev_tags"
    static let AdditivesOldNKey = "additives_old_n"
    static let CategoriesPrevHierarchyKey = "categories_prev_hierarchy"
    static let CreatedTKey = "created_t"
    static let ProductNameKey = "product_name"
    static let IngredientsFromOrThatMayBeFromPalmOilNKey = "ingredients_from_or_that_may_be_from_palm_oil_n"
    static let CreatorKey = "creator"
    static let ImageFrontUrlKey = "image_front_url"
    static let NoNutritionDataKey = "no_nutrition_data" // TBD
    static let ServingSizeKey = "serving_size"
    static let CompletedTKey = "completed_t"
    static let LastModifiedByKey = "last_modified_by"
    static let NewAdditivesNKey = "new_additives_n"
    static let AdditivesPrevTagsKey = "additives_prev_tags"
    static let OriginsKey = "origins"
    static let StoresKey = "stores"
    static let NutritionGradesKey = "nutrition_grades"
    static let NutritionGradeFrKey = "nutrition_grade_fr"
    static let NutrientLevelsKey = "nutrient_levels"
    static let NutrientLevelsSaltKey = "salt"
    static let NutrientLevelsFatKey = "fat"
    static let NutrientLevelsSugarsKey = "sugars"
    static let NutrientLevelsSaturatedFatKey = "saturated-fat"
    static let AdditivesPrevKey = "additives_prev"
    static let StoresTagsKey = "stores_tags"
    static let IdKey = "id"
    static let CountriesKey = "countries"
    static let ImageFrontThumbUrlKey = "image_front_thumb_url"
    static let PurchasePlacesTagsKey = "purchase_places_tags"
    static let TracesHierarchyKey = "traces_hierarchy"
    static let InterfaceVersionModifiedKey = "interface_version_modified"
    static let FruitsVegetablesNuts100gEstimateKey = "fruits-vegetables-nuts_100g_estimate"
    static let ImageThumbUrlKey = "image_thumb_url"
    static let SortkeyKey = "sortkey"
    static let ImageNutritionThumbUrlKey = "image_nutrition_thumb_url"
    static let LastModifiedTKey = "last_modified_t"
    static let ImageIngredientsUrlKey = "image_ingredients_url"
    static let NutritionScoreDebugKey = "nutrition_score_debug"
    static let ImageNutritionSmallUrlKey = "image_nutrition_small_url"
    static let CorrectorsTagsKey = "correctors_tags"
    static let CorrectorsKey = "correctors"
    static let CategoriesDebugTagsKey = "categories_debug_tags"
    static let BrandsKey = "brands"
    static let IngredientsTagsKey = "ingredients_tags"
    static let CodesTagsKey = "codes_tags"
    static let StatesKey = "states"
    static let InformersKey = "informers"
    static let EntryDatesTagsKey = "entry_dates_tags"
    static let ImageIngredientsSmallUrlKey = "image_ingredients_small_url"
    static let NutritionGradesTagsKey = "nutrition_grades_tags"
    static let PackagingKey = "packaging"
    static let ServingQuantityKey = "serving_quantity"
    static let OriginsTagsKey = "origins_tags"
    static let ManufacturingPlacesTagsKey = "manufacturing_places_tags"
    static let NutritionDataPerKey = "nutrition_data_per"
    static let LabelsKey = "labels"
    static let CitiesTagsKey = "cities_tags"
    static let EmbCodes20141016Key = "emb_codes_20141016"
    static let CategoriesTagsKey = "categories_tags"
    static let QuantityKey = "quantity"
    static let LabelsPrevHierarchyKey = "labels_prev_hierarchy"
    static let ExpirationDateKey = "expiration_date"
    static let StatesHierarchyKey = "states_hierarchy"
    static let AllergensTagsKey = "allergens_tags"
    static let AllergensKey = "allergens"
    static let AllergensHierarchyKey = "allergens_hierarchy"
    static let IngredientsThatMayBeFromPalmOilNKey = "ingredients_that_may_be_from_palm_oil_n"
    static let ImageIngredientsThumbUrlKey = "image_ingredients_thumb_url"
    static let IngredientsFromPalmOilNKey = "ingredients_from_palm_oil_n"
    static let ImageUrlKey = "image_url"
    static let IngredientsKey = "ingredients" // TBD
    static let IngredientsElementTextKey = "text"
    static let IngredientsElementRankKey = "rank"
    static let IngredientsElementIdKey = "id"
    static let LcKey = "lc"
    static let IngredientsDebugKey = "ingredients_debug"
    static let PnnsGroups1TagsKey = "pnns_groups_1_tags"
    static let CheckersKey = "checkers"
    static let AdditivesKey = "additives"
    static let CompleteKey = "complete"
    static let AdditivesDebugTagsKey = "additives_debug_tags"
    static let IngredientsIdsDebugKey = "ingredients_ids_debug"
    
    static let PeriodsAfterOpeningKey = "periods_after_opening"
    static let NewServerKey = "new_server"
    
    // specific keys for product lists
    static let SkipKey = "skip"  // Int
    static let PageSizeKey = "page_size" // Int
    static let ProductsKey = "products" //Array
    static let PageKey = "page" // Int
    static let CountKey = "count" // Int
}


