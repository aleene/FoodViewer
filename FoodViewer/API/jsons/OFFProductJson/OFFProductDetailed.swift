//
//  OFFProductDetailed.swift
//  FoodViewer
//
//  Created by arnaud on 09/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//
// Not all keys are readible with the out of the box swift decoder
// Any fields that require extra procesiing can be put here
import Foundation

class OFFProductDetailed: OFFProduct {
    
    struct DetailedKeys : CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        var intValue: Int? { return nil }
        init?(intValue: Int) { return nil }
        
        static let code = DetailedKeys(stringValue: "code")!
        static let codes_tags = DetailedKeys(stringValue: "codes_tags")!
        static let completeness = DetailedKeys(stringValue: "completeness")!
        static let ingredients_n = DetailedKeys(stringValue: "ingredients_n")!
        static let additives_n = DetailedKeys(stringValue: "additives_n")!
        static let additives_old_n = DetailedKeys(stringValue: "additives_old_n")!
        static let carbon_footprint_from_known_ingredients_debug = DetailedKeys(stringValue: "carbon_footprint_from_known_ingredients_debug")!
        static let carbon_footprint_percent_of_known_ingredients = DetailedKeys(stringValue: "carbon_footprint_percent_of_known_ingredients")!
        static let ingredients_from_or_that_may_be_from_palm_oil_n = DetailedKeys(stringValue: "ingredients_from_or_that_may_be_from_palm_oil_n")!
        static let ingredients_from_palm_oil_n = DetailedKeys(stringValue: "ingredients_from_palm_oil_n")!
        static let ingredients_that_may_be_from_palm_oil_n = DetailedKeys(stringValue: "ingredients_that_may_be_from_palm_oil_n")!
        static let languages_codes = DetailedKeys(stringValue: "languages_codes")!
        static let max_imgid = DetailedKeys(stringValue: "max_imgid")!
        static let nova_group = DetailedKeys(stringValue: "nova_group")!
        static let nova_groups = DetailedKeys(stringValue: "nova_groups")!
        static let novaDashgroup = DetailedKeys(stringValue: "nova-group")!
        static let novaDashgroup_100g = DetailedKeys(stringValue: "nova-group_100g")!
        static let novaDashgroup_serving = DetailedKeys(stringValue: "nova-group_serving")!
        static let nutrition_score_warning_fruits_vegetables_nuts_estimate_from_ingredients_value = DetailedKeys(stringValue: "nutrition_score_warning_fruits_vegetables_nuts_estimate_from_ingredients_value")!
        static let popularity_key = DetailedKeys(stringValue: "popularity_key")!
        static let rev = DetailedKeys(stringValue: "rev")!
        static let product_quantity = DetailedKeys(stringValue: "product_quantity")!
        static let serving_quantity = DetailedKeys(stringValue: "serving_quantity")!
        static let sortkey = DetailedKeys(stringValue: "sortkey")!
        static let unknown_ingredients_n = DetailedKeys(stringValue: "unknown_ingredients_n")!

    }

    private struct KeyPreFix {
        static let ConservationConditions = "conservation_conditions_"
        static let CustomerService = "customer_service_"
        static let ProductName = "product_name_"
        static let GenericName = "generic_name_"
        static let IngredientsText = "ingredients_text_"
        static let IngredientsTextWithAllergens = "ingredients_text_with_allergens_"
        static let OtherInformation = "other_information_"
        static let Preparation = "preparation_"
        static let Producer = "producer_"
        static let Warning = "warning_"
    }
    
    var code: String? = nil
    var codes_tags: [String]? = nil
    var additives_n: Int? = nil
    var additives_old_n: Int? = nil
    var carbon_footprint_from_known_ingredients_debug: Int? = nil
    var carbon_footprint_percent_of_known_ingredients: Double? = nil
    var customer_service_: [String:String] = [:]
    var completeness: Double? = nil
    var conservation_conditions_: [String:String] = [:]
    var generic_names_: [String:String] = [:]
    var ingredients_from_or_that_may_be_from_palm_oil_n: Int? = nil
    var ingredients_from_palm_oil_n: Int? = nil
    var ingredients_n: Int? = nil
    var ingredients_texts_: [String:String] = [:]
    var ingredients_texts_with_allergens_: [String:String] = [:]
    var ingredients_that_may_be_from_palm_oil_n: Int? = nil
    var languages_codes: [String:Int] = [:]
    var nova_group: String? = nil
    var nova_groups: String? = nil
    var novaDashgroup: String? = nil
    var novaDashgroup_100g: String? = nil
    var novaDashgroup_serving: String? = nil
    var nutrition_score_warning_fruits_vegetables_nuts_estimate_from_ingredients_value: Double? = nil
    var max_imgid: String? = nil
    var other_information_: [String:String] = [:]
    var popularity_key: Int? = nil
    var preparation_: [String:String] = [:]
    var producer_: [String:String] = [:]
    var product_names_: [String:String] = [:]
    var product_quantity: String? = nil
    var rev: Int? = nil
    var serving_quantity: Double? = nil
    var sortkey: Int?
    var unknown_ingredients_n: Int? = nil
    var warning_: [String:String] = [:]

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DetailedKeys.self)
        
        // I need the language_code to build the keys
        do {
            languages_codes = try container.decode(Dictionary.self, forKey: .languages_codes)
        } catch {
            //
        }
        
        self.carbon_footprint_from_known_ingredients_debug = container.forceInt(key: .carbon_footprint_from_known_ingredients_debug)
        self.completeness = container.forceDouble(key: .completeness)
        self.carbon_footprint_percent_of_known_ingredients = container.forceDouble(key: .carbon_footprint_percent_of_known_ingredients)
        self.max_imgid = container.forceString(key: .max_imgid)
        self.rev = container.forceInt(key: .rev)
        self.sortkey = container.forceInt(key: .sortkey)
        self.code = container.forceString(key: .code)
        self.ingredients_n = container.forceInt(key: .ingredients_n)
        self.additives_n = container.forceInt(key: .additives_n)
        self.additives_old_n = container.forceInt(key: .additives_old_n)
        self.ingredients_from_or_that_may_be_from_palm_oil_n = container.forceInt(key: .ingredients_from_or_that_may_be_from_palm_oil_n)
        self.ingredients_from_palm_oil_n = container.forceInt(key: .ingredients_from_palm_oil_n)
        self.ingredients_that_may_be_from_palm_oil_n = container.forceInt(key: .ingredients_that_may_be_from_palm_oil_n)
        self.serving_quantity = container.forceDouble(key: .serving_quantity)
        self.nova_group = container.forceString(key: .nova_group)
        self.nova_groups = container.forceString(key: .nova_groups)
        self.novaDashgroup = container.forceString(key: .novaDashgroup)
        self.novaDashgroup_100g = container.forceString(key: .novaDashgroup_100g)
        self.novaDashgroup_serving = container.forceString(key: .novaDashgroup_serving)
        self.nutrition_score_warning_fruits_vegetables_nuts_estimate_from_ingredients_value = container.forceDouble(key: .nutrition_score_warning_fruits_vegetables_nuts_estimate_from_ingredients_value)
        self.product_quantity = container.forceString(key: .product_quantity)
        self.unknown_ingredients_n = container.forceInt(key: .unknown_ingredients_n)
        self.popularity_key = container.forceInt(key: .popularity_key)

        do {
            self.codes_tags = try container.decode(Array.self, forKey: .codes_tags)
        } catch {
            do {
                let intCode = try container.decode(Int.self, forKey: .code)
                self.codes_tags = ["\(intCode)"]
            } catch {
                self.codes_tags = nil
            }
        }
        
        // try to extract all language specific fields
        for languageCode in languages_codes {
            for key in container.allKeys {
                if key.stringValue == KeyPreFix.ConservationConditions + languageCode.key {
                    do {
                        let name = try container.decode(String.self, forKey: key)
                        conservation_conditions_[languageCode.key] = name
                    }
                }
                if key.stringValue == KeyPreFix.CustomerService + languageCode.key {
                    do {
                        let name = try container.decode(String.self, forKey: key)
                        customer_service_[languageCode.key] = name
                    }
                }
                if key.stringValue == KeyPreFix.GenericName + languageCode.key {
                    do {
                        let name = try container.decode(String.self, forKey: key)
                        generic_names_[languageCode.key] = name
                    }
                }
                if key.stringValue == KeyPreFix.IngredientsText + languageCode.key {
                    do {
                        let name = try container.decode(String.self, forKey: key)
                        ingredients_texts_[languageCode.key] = name
                    }
                }
                if key.stringValue == KeyPreFix.Preparation + languageCode.key {
                    do {
                        let name = try container.decode(String.self, forKey: key)
                        preparation_[languageCode.key] = name
                    }
                }
                if key.stringValue == KeyPreFix.Producer + languageCode.key {
                    do {
                        let name = try container.decode(String.self, forKey: key)
                        producer_[languageCode.key] = name
                    }
                }
                if key.stringValue ==  KeyPreFix.ProductName + languageCode.key {
                    do {
                        let name = try container.decode(String.self, forKey: key)
                        product_names_[languageCode.key] = name
                    }
                }
                if key.stringValue == KeyPreFix.Warning + languageCode.key {
                    do {
                        let name = try container.decode(String.self, forKey: key)
                        warning_[languageCode.key] = name
                    }
                }
                /*
                if key.stringValue ==  KeyPreFix.IngredientsTextWithAllergens + languageCode.key {
                    do {
                        let name = try container.decode(String.self, forKey: key)
                        ingredients_texts_with_allergens_[languageCode.key] = name
                    } catch let error {
                        print("OFFProductDetailed", error.localizedDescription)
                    }
                }
                */
            }
        }

        
        // I can init the super only after the child is initialised
        // https://medium.com/tsengineering/swift-4-0-codable-decoding-subclasses-inherited-classes-heterogeneous-arrays-ee3e180eb556
        //
        try super.init(from: decoder)
    }
    
    override init() {
        super.init()
        self.customer_service_ = [:]
        self.conservation_conditions_ = [:]
        self.languages_codes = [:]
        self.generic_names_ = [:]
        self.ingredients_texts_ = [:]
        self.ingredients_texts_with_allergens_ = [:]
        self.other_information_ = [:]
        self.preparation_ = [:]
        self.producer_ = [:]
        self.product_names_ = [:]
        self.warning_ = [:]
    }

    //  This init initialises with the changes that the user can make.
    convenience init(languageCodes: [String],
                     names: [String:String],
                     generic_names: [String:String],
                     ingredients: [String:String],
                     additives_tags: [String],
                     brands_tags: [String],
                     categories_tags: [String],
                     code: String,
                     //conservation_conditions: [String:String],
                     countries_tags: [String],
                     //customer_service: [String:String],
                     emb_codes_tags: [String],
                     expiration_date: String,
                     labels_tags: [String],
                     link: String,
                     manufacturing_places_tags: [String],
                     nutriments: OFFProductNutriments,
                     origins_tags: [String],
                     //other_information: [String:String],
                     packaging_tags: [String],
                     //preparation: [String:String],
                     //producer: [String:String],
                     purchase_places_tags: [String],
                     quantity: String,
                     serving_size: String,
                     stores_tags: [String],
                     traces_tags: [String]
                     //, warning: [String:String]
                    ) {
        
        self.init()
        
        self.additives = additives_tags.joined(separator: ",")
        self.additives_tags = additives_tags
        self.brands = brands_tags.joined(separator: ",")
        self.brands_tags = brands_tags
        self.categories = categories_tags.joined(separator: ",")
        self.categories_tags = categories_tags
        self.code = code
        self.countries = countries_tags.joined(separator: ",")
        self.countries_tags = countries_tags
        self.emb_codes = emb_codes_tags.joined(separator: ",")
        self.emb_codes_tags = emb_codes_tags
        self.expiration_date = expiration_date
        self.labels = labels_tags.joined(separator: ",")
        self.labels_tags = labels_tags
        self.link = link
        self.manufacturing_places = manufacturing_places_tags.joined(separator: ",")
        self.manufacturing_places_tags = manufacturing_places_tags
        self.nutriments = nutriments
        self.origins = origins_tags.joined(separator: ",")
        self.origins_tags = origins_tags
        //self.other_information_ = other_information
        self.packaging = packaging_tags.joined(separator: ",")
        self.packaging_tags = packaging_tags
        self.purchase_places = purchase_places_tags.joined(separator: ",")
        self.purchase_places_tags = purchase_places_tags
        self.quantity = quantity
        self.serving_size = serving_size
        self.stores = stores_tags.joined(separator: ",")
        self.stores_tags = stores_tags
        self.traces = traces_tags.joined(separator: ",")
        self.traces_tags = traces_tags
        // All the other OFFProduct variables do not need to be set and can be nil
        
        // Inititalize the detailedProduct variables
        var newLanguageCodes: [String:Int] = [:]
        for language in languageCodes {
            newLanguageCodes[language] = 0
        }
        self.languages_codes = newLanguageCodes
       // self.conservation_conditions_ = conservation_conditions
        //self.customer_service_ = customer_service
        self.product_names_ = names
        self.generic_names_ = generic_names
        self.ingredients_texts_ = ingredients
        //self.preparation_ = preparation
        //self.producer_ = producer
        //self.warning_ = warning
    }
    
    override func encode(to encoder: Encoder) throws {
        do {
            try super.encode(to: encoder)
        } catch {
            print("OFFProductDetailed: encoder borker")
        }
        
        var container = encoder.container(keyedBy: DetailedKeys.self)
        
        try container.encode(languages_codes, forKey: .languages_codes)
        try container.encode(code, forKey: .code)
        if let validServingQuantity = serving_quantity {
            try container.encode(validServingQuantity, forKey: .serving_quantity)
        }
        
        for (languageCode, _) in languages_codes {
            if let key = DetailedKeys(stringValue: KeyPreFix.ConservationConditions + languageCode) {
                try container.encodeIfPresent(conservation_conditions_[languageCode], forKey: key)
            }
            if let key = DetailedKeys(stringValue: KeyPreFix.CustomerService + languageCode) {
                try container.encodeIfPresent(customer_service_[languageCode], forKey: key)
            }
            if let key = DetailedKeys(stringValue: KeyPreFix.GenericName + languageCode) {
                try container.encodeIfPresent(generic_names_[languageCode], forKey: key)
            }
            if let key = DetailedKeys(stringValue: KeyPreFix.IngredientsText + languageCode) {
                try container.encodeIfPresent(ingredients_texts_[languageCode], forKey: key)
            }
            if let key = DetailedKeys(stringValue: KeyPreFix.OtherInformation + languageCode) {
                try container.encodeIfPresent(other_information_[languageCode], forKey: key)
            }
            if let key = DetailedKeys(stringValue: KeyPreFix.Preparation + languageCode) {
                try container.encodeIfPresent(preparation_[languageCode], forKey: key)
            }
            if let key = DetailedKeys(stringValue: KeyPreFix.Producer + languageCode) {
                try container.encodeIfPresent(producer_[languageCode], forKey: key)
            }
            if let key = DetailedKeys(stringValue: KeyPreFix.ProductName + languageCode) {
                try container.encodeIfPresent(product_names_[languageCode], forKey: key)
            }
            if let key = DetailedKeys(stringValue: KeyPreFix.Warning + languageCode) {
                try container.encodeIfPresent(warning_[languageCode], forKey: key)
            }
        }
    }
}
