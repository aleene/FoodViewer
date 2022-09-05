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
            static let Packaging = "packaging"
        }
        //public struct ImageSize {
        //    static let Thumb = ".100"
        //    static let Small = ".200"
        //    static let Display = ".400"
        //    static let Original = ""
        //}
        public struct Divider {
            static let Slash = "/"
            static let Dot = "."
            static let Equal = "="
            static let QuestionMark = "?"
            static let Ampersand = "&"
        }
        public struct PartNumber {
            static let Barcode = 5
        }
        
        static let Scheme = "https://"
        static let Prefix = "https://world."
        static let PrefixRobotoff = "robotoff."
        static let TopDomain = ".org/"
        static let AdvancedSearch = "cgi/search.pl?action=process"
        static let EnglishProduct = "en" + Product
        static let Product = "product"
        static let Postfix = ".org/api/v1.2/product/"
        // /api/v1/questions/
        static let PostfixRobotoff = ".org/api/v1/questions"
        static let JSONExtension = ".json"
        static let JSONSearchExtension = "&json=1"
        static let SearchPage = "&page="
        static let JPGextension = ".jpg"
        static let Fields = "fields="
        static let Language = "lc="
        static let Images = "images/products/"
        struct Search {
            struct Tag {
                static let Tiep = "&tagtype_"
                static let Contains = "&tag_contains_"
                static let Value = "&tag_"
                static let DoesContain = "contains"
                static let DoesNotContain = "does_not_contain"
            }
            struct Nutriments {
                static let Tiep = "&nutriment_"
                static let Compare = "&nutriment_compare_"
                struct Operator {
                    static let LT = "lt"
                    static let LTE = "lte"
                    static let GT = "gt"
                    static let GTE = "gte"
                    static let EQ = "eq"
                }
                static let Value = "&nutriment_value_"
            }
            static let Terms = "&search_terms="
        }
    }
    
    public enum Server: String {
        case food = "openfoodfacts"
        case beauty = "openbeautyfacts"
        case petFood = "openpetfoodfacts"
        case product = "openproductfacts"
    }
    
    public enum ImageSize: String {
        case thumb = "100"
        case medium = "200"
        case large = "400"
        case original = "original"
    }
    
    private static func string(for component: SearchComponent) -> (String?, String?) {
        // The strings are needed for creating the search url. 
        // The first string is for a simple query
        // The second is for an advanced query
        switch component {
        case .barcode:
            return ("code", nil)
        case .searchText:
            return (nil, "searchText")
        case .brand:
            return ("brand", "brands")
        case .category:
            return ("category", "categories")
        case .country:
            return ("country", "countries")
        case .label:
            return ("label", "labels")
        case .language:
            return ("language", "languages")
        case .packaging:
            return ("packaging", "packaging")
        case .origin:
            return ("origin", "origins")
        case .purchasePlace:
            return ("purchase_place", "purchase_places")
        case .additive:
            return ("additive", "additives")
        case .trace:
            return ("trace", "traces")
        case .allergen:
            return ("allergen", "allergens")
        case .producerCode:
            return ("packager-code", "emb_codes")
        case .manufacturingPlaces:
            return ("manufacturing-place", "manufacturing-places")
        case .store:
            return ("store", "stores")
        case .ingredient:
            return ("ingredient", nil)
        case .entryDates:
            return ("entry-date", nil)
        case .lastEditDate:
            return ("last-edit-date", nil)
        case .contributor:
            return ("contributor", "contributors")
        case .creator:
            return ("creator", "creator")
        case .checker:
            return ("checker", "checkers")
        case .informer:
            return ("informer", "informers")
        case .editor:
            return ("editor", "editors")
        case .photographer:
            return ("photographer", "photographers")
        case .corrector:
            return ("corrector", "correctors")
        case .state:
            return ("state", "states")
        case .nutritionGrade:
            return ("nutrition_grade", "nutrition_grades")
        case .nutrient:
            return (nil, "nutrient")
        }
    }

    // The base strings which represent the various states on OFF
    public static func string(for completion: ProductCompletion) -> String {
        switch completion.category {
        case .productName: // in JSON and search
            return "product-name"
        case .brands:
            return "brands" // in JSON and search
        case .quantity:
            return "quantity" // in JSON and search
        case .frontPhoto:
            return "front-photo"
        case .packaging:
            return "packaging" // in JSON and search
        case .ingredients:
            return "ingredients" // in JSON and search
        case .ingredientsPhoto:
            return "ingredients-photo"
        case .nutritionPhoto:
            return "nutrition-photo"
        case .categories:
            return "categories" // in JSON and search
        case .expirationDate:
            return "expiration-date" // in JSON and search
        case .nutritionFacts:
            return "nutrition-facts" // in JSON and search
        case .photosUploaded:
            return "photos-uploaded" // in JSON and search
        case .origins:
            return "origins"
        case .photosValidated:
            return "photos-validated" // in JSON and search
        case .packagingPhoto:
            return "packaging-photo" // in JSON and search
        case .complete:
            return "complete"
        case .characteristics:
            return "characteristics"
        case .packagingCode:
            return "packaging-code"
        case .checked:
            return "checked"
        }
    }
    
    public static var allCompletionStates: [ProductCompletion] {
        return [ProductCompletion.init(.productName, isCompleted: true),
            ProductCompletion.init(.brands, isCompleted: true),
            ProductCompletion.init(.quantity, isCompleted: true),
            ProductCompletion.init(.packaging, isCompleted: true),
            ProductCompletion.init(.ingredients, isCompleted: true),
            ProductCompletion.init(.categories, isCompleted: true),
            ProductCompletion.init(.expirationDate, isCompleted: true),
            ProductCompletion.init(.nutritionFacts, isCompleted: true),
            ProductCompletion.init(.frontPhoto, isCompleted: true),
            ProductCompletion.init(.ingredientsPhoto, isCompleted: true),
            ProductCompletion.init(.nutritionPhoto, isCompleted: true),
            ProductCompletion.init(.packagingPhoto, isCompleted: true),
            ProductCompletion.init(.photosUploaded, isCompleted: true),
            ProductCompletion.init(.photosValidated, isCompleted: true)]
    }

    // The value strings needed for searching a status
    public static func searchKey(for completion:ProductCompletion) -> String {
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
    public static func JSONkey(for completion:ProductCompletion) -> String {
        return "en:" + searchKey(for:completion)
    }
    
    // Convert the key values found in the JSON to a Completion
    public static func JSONcompletion(for string: String) -> ProductCompletion? {
        // remove the language component
        let elements = string.split(separator:":").map(String.init)
        if elements.count > 1 {
            return completion(for:elements[1])
        }
        return nil
    }

    // Converts the status searchKey back to a Completion object
    static func completion(for string: String) -> ProductCompletion? {
        
        if string == searchKey(for: ProductCompletion.init(.productName, isCompleted:true)) {
            return ProductCompletion.init(.productName, isCompleted:true)
        } else if string == searchKey(for: ProductCompletion.init(.productName, isCompleted:false)) {
            return ProductCompletion.init(.productName, isCompleted:false)
            
        } else if string == searchKey(for: ProductCompletion.init(.brands, isCompleted:true)) {
            return ProductCompletion.init(.brands, isCompleted:true)
        } else if string == searchKey(for: ProductCompletion.init(.brands, isCompleted:false)) {
            return ProductCompletion.init(.brands, isCompleted:false)
            
        } else if string == searchKey(for: ProductCompletion.init(.quantity, isCompleted:true)) {
            return ProductCompletion.init(.quantity, isCompleted:true)
        } else if string == searchKey(for: ProductCompletion.init(.quantity, isCompleted:false)) {
            return ProductCompletion.init(.quantity, isCompleted:false)
            
        } else if string == searchKey(for: ProductCompletion.init(.packaging, isCompleted:true)) {
            return ProductCompletion.init(.packaging, isCompleted:true)
        } else if string == searchKey(for: ProductCompletion.init(.packaging, isCompleted:false)) {
            return ProductCompletion.init(.packaging, isCompleted:false)
            
        } else if string == searchKey(for: ProductCompletion.init(.ingredients, isCompleted:true)) {
            return ProductCompletion.init(.ingredients, isCompleted:true)
        } else if string == searchKey(for: ProductCompletion.init(.ingredients, isCompleted:false)) {
            return ProductCompletion.init(.ingredients, isCompleted:false)
            
        } else if string == searchKey(for: ProductCompletion.init(.categories, isCompleted:true)) {
            return ProductCompletion.init(.categories, isCompleted:true)
        } else if string == searchKey(for: ProductCompletion.init(.categories, isCompleted:false)) {
            return ProductCompletion.init(.categories, isCompleted:false)
            
        } else if string == searchKey(for: ProductCompletion.init(.expirationDate, isCompleted:true)) {
            return ProductCompletion.init(.expirationDate, isCompleted:true)
        } else if string == searchKey(for: ProductCompletion.init(.expirationDate, isCompleted:false)) {
            return ProductCompletion.init(.expirationDate, isCompleted:false)
            
        } else if string == searchKey(for: ProductCompletion.init(.nutritionFacts, isCompleted:true)) {
            return ProductCompletion.init(.nutritionFacts, isCompleted:true)
        } else if string == searchKey(for: .init(.nutritionFacts, isCompleted:false)) {
            return ProductCompletion.init(.nutritionFacts, isCompleted:false)
            
        } else if string == searchKey(for: ProductCompletion.init(.photosUploaded, isCompleted:true)) {
            return ProductCompletion.init(.photosUploaded, isCompleted:true)
        } else if string == searchKey(for: ProductCompletion.init(.photosUploaded, isCompleted:false)) {
            return ProductCompletion.init(.photosUploaded, isCompleted:false)
            
        } else if string == searchKey(for: ProductCompletion.init(.photosValidated, isCompleted:true)) {
            return ProductCompletion.init(.photosValidated, isCompleted:true)
        } else if string == searchKey(for: ProductCompletion.init(.photosValidated, isCompleted:false)) {
            return ProductCompletion.init(.photosValidated, isCompleted:false)
        }
        return nil
    }

    static func fetchString(for barcode: BarcodeType, with productType: ProductType) -> String {
        var fetchUrlString = URL.Prefix
        // add the right server
        fetchUrlString += productType.rawValue
        fetchUrlString += URL.Postfix
        fetchUrlString += barcode.asString + URL.JSONExtension
        return fetchUrlString
    }
    
    static func fetchAttributesString(for barcode: BarcodeType, with productType: ProductType, languageCode: String) -> String {
        var fetchUrlString = URL.Prefix
        // add the right server
        fetchUrlString += productType.rawValue
        fetchUrlString += URL.Postfix
        fetchUrlString += barcode.asString
        fetchUrlString += URL.Divider.QuestionMark
        fetchUrlString += URL.Fields
        fetchUrlString += "attribute_groups"
        fetchUrlString += URL.Divider.Ampersand
        fetchUrlString += URL.Language
        fetchUrlString += languageCode
        return fetchUrlString
    }

    // https://robotoff.openfoodfacts.org/api/v1/questions/3033490004743?lang=en&count=6"
/*
Retrieve the robotoff questions for a product
 Parameters:
 - barcode:
- productType: the type of product (food, petfood, beauty, rest)
     - languageCode: the required languageCode of the result (default en)
*/
    static func fetchQuestionsString(for barcode: BarcodeType?, with productType: ProductType, languageCode: String, count: Int?) -> String {
        var fetchUrlString = URL.Scheme
        fetchUrlString += URL.PrefixRobotoff
        // add the right server (works only for food products)
        fetchUrlString += productType.rawValue
        fetchUrlString += URL.PostfixRobotoff
        if let validBarcode = barcode {
            fetchUrlString += URL.Divider.Slash
            fetchUrlString += validBarcode.asString
        }
        fetchUrlString += URL.Divider.QuestionMark
        fetchUrlString += "lang="
        fetchUrlString += languageCode
        if let validCount = count,
            validCount > 0  {
            fetchUrlString += URL.Divider.QuestionMark
            fetchUrlString += "count="
            fetchUrlString += "\(validCount)"
        }
        return fetchUrlString
    }

    static func simpleSearchString(for template: SearchTemplate, on page: Int ) -> String {
        
        // let region = Bundle.main.preferredLocalizations[0] as NSString
        var urlString = OFF.URL.Prefix
        // use the currrent product type
        urlString += server(for:Preferences.manager.showProductType)
        urlString += URL.TopDomain
        for pair in template.searchPairsWithArray() {
            if let validString = string(for:pair.0).0 {
                for element in pair.1 {
                    urlString += validString
                    urlString += "/"
                    urlString += element
                    urlString += "/"
                }
            }
        }
        urlString += "\(page)"
        urlString += URL.JSONExtension
        return urlString
    }
    
    static func searchString(for template: SearchTemplate, on page: Int ) -> String {
        if template.type == .simple {
            return simpleSearchString(for: template, on: page)
        } else {
            return advancedSearchString(for: template, on: page)
        }
    }
    
    // This functions builds an url for an advanced search
    static func advancedSearchString(for template: SearchTemplate, on page: Int ) -> String {
        // https://world.openfoodfacts.org/cgi/search.pl?search_terms=banania&search_simple=1&action=process&json=1
        // https://world.openfoodfacts.org/cgi/search.pl?action=process&tagtype_0=brands&tag_contains_0=contains&tag_0=Coca
        
        var urlString = OFF.URL.Prefix
        // use the currrent product type
        urlString += server(for:Preferences.manager.showProductType)
        urlString += URL.TopDomain
        urlString += URL.AdvancedSearch
        
        // Set a generic search
        
        if let validText = template.text {
            urlString += URL.Search.Terms
            urlString += validText
        }
        
        // Set search tags
        
        var search_tag_index = 0
        urlString += addSearchTag(template.brands, in: .brand, index: &search_tag_index) ?? ""
        urlString += addSearchTag(template.languages, in: .language, index: &search_tag_index) ?? ""
        urlString += addSearchTag(template.packaging, in: .packaging, index: &search_tag_index) ?? ""
        urlString += addSearchTag(template.additives, in: .additive, index: &search_tag_index) ?? ""
        urlString += addSearchTag(template.allergens, in: .allergen, index: &search_tag_index) ?? ""
        urlString += addSearchTag(template.traces, in: .trace, index: &search_tag_index) ?? ""
        urlString += addSearchTag(template.labels, in: .label, index: &search_tag_index) ?? ""
        urlString += addSearchTag(template.origins, in: .origin, index: &search_tag_index) ?? ""
        urlString += addSearchTag(template.manufacturing_places, in: .manufacturingPlaces, index: &search_tag_index) ?? ""
        urlString += addSearchTag(template.emb_codes, in: .producerCode, index: &search_tag_index) ?? ""
        urlString += addSearchTag(template.purchase_places, in: .purchasePlace, index: &search_tag_index) ?? ""
        urlString += addSearchTag(template.stores, in: .store, index: &search_tag_index) ?? ""
        urlString += addSearchTag(template.countries, in: .country, index: &search_tag_index) ?? ""
        urlString += addSearchTag(template.categories, in: .category, index: &search_tag_index) ?? ""
        
        if template.level != nil && template.level! != .undefined {
            let tags = Tags.init(list:[template.level!.rawValue])
            // The contain value is always set to true as it is encoded in the tags value.
            urlString += addSearchTag((tags, true), in: .nutritionGrade, index: &search_tag_index) ?? ""
        }
      
        // encode completion to: 
        //      tagtype_0=states&tag_contains_0=contains&tag_0=Product%20name%20to%20be%20completed
        //
        if let completion = template.completion {
            urlString += addSearchTag((Tags.init(list:[searchKey(for:completion).replacingOccurrences(of: "-", with: " ")]), true), in: .state, index: &search_tag_index) ?? ""
        }
        // Add the search parts for all nutriments
        
        search_tag_index = 0
        for nutriment in template.allNutrimentsSearch {
                urlString += URL.Search.Nutriments.Tiep
                urlString += "\(search_tag_index)"
                urlString += URL.Divider.Equal
                urlString += nutriment.nutrient.key
                urlString += URL.Search.Nutriments.Compare
                urlString += "\(search_tag_index)"
                urlString += URL.Divider.Equal
                switch nutriment.searchOperator {
                case .lessThan:
                    urlString += URL.Search.Nutriments.Operator.LT
                case .lessThanOrEqual:
                    urlString += URL.Search.Nutriments.Operator.LTE
                case .greaterThan:
                    urlString += URL.Search.Nutriments.Operator.GT
                case .greaterThanOrEqual:
                    urlString += URL.Search.Nutriments.Operator.GTE
                case .equal:
                    urlString += URL.Search.Nutriments.Operator.EQ
                }
                urlString += URL.Search.Nutriments.Value
                urlString += "\(search_tag_index)"
                urlString += URL.Divider.Equal
                urlString += "\(nutriment.value)"
                
                search_tag_index += 1
        }
        
        for contributor in template.contributors {
            if contributor.isCreator {
                // &tagtype_0=creator&tag_contains_0=contains&tag_0=aleene
                urlString += addSearchTag((Tags.init(list:[contributor.name]), true), in: .creator, index: &search_tag_index) ?? ""
            }
            if contributor.isEditor {
                // &tagtype_0=editors&tag_contains_0=contains&tag_0=aleene
                urlString += addSearchTag((Tags.init(list:[contributor.name]), true), in: .editor, index: &search_tag_index) ?? ""
            }
            if contributor.isInformer {
                // &tagtype_0=editors&tag_contains_0=contains&tag_0=aleene
                urlString += addSearchTag((Tags.init(list:[contributor.name]), true), in: .informer, index: &search_tag_index) ?? ""
            }
            if contributor.isCorrector {
                // &tagtype_0=editors&tag_contains_0=contains&tag_0=aleene
                urlString += addSearchTag((Tags.init(list:[contributor.name]), true), in: .corrector, index: &search_tag_index) ?? ""
            }
            if contributor.isChecker {
                // &tagtype_0=editors&tag_contains_0=contains&tag_0=aleene
                urlString += addSearchTag((Tags.init(list:[contributor.name]), true), in: .checker, index: &search_tag_index) ?? ""
            }

            if contributor.isPhotographer {
                // &tagtype_0=editors&tag_contains_0=contains&tag_0=aleene
                urlString += addSearchTag((Tags.init(list:[contributor.name]), true), in: .photographer, index: &search_tag_index) ?? ""
            }

        }
        urlString += URL.SearchPage + "\(page)"
        urlString += sortString(template.sortOrder)
        urlString += URL.JSONSearchExtension
        return urlString
    }
    
    static func sortString(_ sortOrder:SearchSortOrder) -> String {
        switch sortOrder {
        case .popularity:
            return "&sort_by=unique_scans_n"
        case .productName:
            return "&sort_by=product_name"
        case .addDate:
            return "&sort_by=created_t"
        case .editDate:
            return "&sort_by=last_modified_t"
        }
    }
   
    // Convert a search tag pair to a part of an advanced search url
    static private func addSearchTag(_ pair: (Tags, Bool)?, in component:SearchComponent, index: inout Int) -> String? {
        if let (tags, shouldContain) = pair {
            if !tags.list.isEmpty {
                var urlString = ""
                for item in tags.list {
                    urlString += URL.Search.Tag.Tiep
                    urlString += "\(index)"
                    urlString += URL.Divider.Equal
                    if let validString = string(for:component).1 {
                        urlString += validString
                    } else {
                        continue
                    }
                    urlString += URL.Search.Tag.Contains
                    urlString += "\(index)"
                    urlString += URL.Divider.Equal
                    
                    urlString += shouldContain ? URL.Search.Tag.DoesContain : URL.Search.Tag.DoesNotContain
                    
                    urlString += URL.Search.Tag.Value
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
        urlString += server(for:barcode.productType ?? .food)
        urlString += OFF.URL.TopDomain
        urlString += TranslatableStrings.Product.lowercased()
        urlString += OFF.URL.Divider.Slash
        urlString += barcode.asString
        urlString += OFF.URL.Divider.Slash
        return urlString
    }
    
    static func imageURLFor(_ barcode: BarcodeType) -> String {
        let region = Bundle.main.preferredLocalizations[0] as NSString
        var urlString = OFF.URL.Scheme
        urlString += "\(region)."
        urlString += server(for:barcode.productType ?? .food)
        urlString += OFF.URL.TopDomain
        urlString += OFF.URL.Images
        if let str = imageURLComponentFor(barcode.asString) {
            urlString += str
        }
        urlString += OFF.URL.Divider.Slash
        return urlString
    }
    
    // https://world.openfoodfacts.org/images/products/803/409/462/0006/3.100.jpg
    
    static func imageURLFor(_ barcode: BarcodeType, with id:String, size:ImageSizeCategory) -> String {
        let region = Bundle.main.preferredLocalizations[0] as NSString
        var urlString = OFF.URL.Scheme
        urlString += "\(region)."
        urlString += server(for:barcode.productType ?? .food)
        urlString += OFF.URL.TopDomain
        urlString += OFF.URL.Images
        if let str = imageURLComponentFor(barcode.asString) {
            urlString += str
        }
        urlString += OFF.URL.Divider.Slash
        urlString += id
        switch size {
        case .thumb:
            urlString += OFF.URL.Divider.Dot
            urlString += ImageSizeCategory.thumb.size
        case .small:
            urlString += OFF.URL.Divider.Dot
            urlString += ImageSizeCategory.small.size
        case .display:
            urlString += OFF.URL.Divider.Dot
            urlString += ImageSizeCategory.display.size
        case .original:
            urlString += ImageSizeCategory.original.size
        default:
            assert(false, "OFF.imageURLFor(_:with:size:)")
        }
        urlString += OFF.URL.JPGextension
        return urlString
    }

    static func imageURLComponentFor(_ barcode: String) -> String? {
        if barcode.count == 8 {
            // Lidl product
            return barcode
        } else if barcode.count == 10
            || barcode.count == 11
            || barcode.count == 12
            || barcode.count == 13
            || barcode.count == 22
            || barcode.count == 27 {
            // US products
            let part1 = barcode.index(barcode.startIndex, offsetBy: 0)...barcode.index(barcode.startIndex, offsetBy: 2)
            let part2 = barcode.index(barcode.startIndex, offsetBy: 3)...barcode.index(barcode.startIndex, offsetBy: 5)
            let part3 = barcode.index(barcode.startIndex, offsetBy: 6)...barcode.index(barcode.startIndex, offsetBy: 8)
            let part4 = barcode.index(barcode.startIndex, offsetBy: 9)...barcode.index(barcode.startIndex, offsetBy: barcode.count - 1 )
    //
            return String(barcode[part1]) + OFF.URL.Divider.Slash +
                String(barcode[part2]) + OFF.URL.Divider.Slash +
                String(barcode[part3]) + OFF.URL.Divider.Slash  +
                barcode[part4]
        }
        print("OFF.imageURLFor(_ barcode) : barcode ", barcode , "can not be translated to url-string")
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
        case .product:
            return OFF.Server.product.rawValue
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
    
    // The nutrient key can be found in the class  Nutrient
    /*
    static let SodiumKey = "sodium"
    static let SaltKey = "salt"
    static let SugarsKey = "sugars"
    static let AddedSugarsKey = "added-sugars"
    static let EnergyKey = "energy"
    static let EnergyKcalKey = "energy-kcal"
    static let EnergyFromFatKey = "energy-from-fat"
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
    */
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
    static let FruitsVegetablesNutsKey = "fruits-vegetables-nuts"
    static let FruitsVegetablesNutsEstimateKey = "fruits-vegetables-nuts-estimate"
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


