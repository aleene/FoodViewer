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
        static let ingredients_n = DetailedKeys(stringValue: "ingredients_n")!
        static let additives_n = DetailedKeys(stringValue: "additives_n")!
        static let additives_old_n = DetailedKeys(stringValue: "additives_old_n")!
        static let carbon_footprint_from_known_ingredients_debug = DetailedKeys(stringValue: "carbon_footprint_from_known_ingredients_debug")!
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
        static let rev = DetailedKeys(stringValue: "rev")!
        static let product_quantity = DetailedKeys(stringValue: "product_quantity")!
        static let serving_quantity = DetailedKeys(stringValue: "serving_quantity")!
        static let sortkey = DetailedKeys(stringValue: "sortkey")!
        static let unknown_ingredients_n = DetailedKeys(stringValue: "unknown_ingredients_n")!

    }

    private struct KeyPreFix {
        static let ProductName = "product_name_"
        static let GenericName = "generic_name_"
        static let IngredientsText = "ingredients_text_"
        static let IngredientsTextWithAllergens = "ingredients_text_with_allergens_"
    }
    
    var code: String? = nil
    var codes_tags: [String]? = nil
    var additives_n: Int? = nil
    var additives_old_n: Int? = nil
    var carbon_footprint_from_known_ingredients_debug: Int? = nil
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
    var max_imgid: String? = nil
    var product_names_: [String:String] = [:]
    var product_quantity: String? = nil
    var rev: Int? = nil
    var serving_quantity: Double? = nil
    var sortkey: Int?
    var unknown_ingredients_n: Int? = nil
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DetailedKeys.self)
        
        // I need the language_code to build the keys
        do {
            languages_codes = try container.decode(Dictionary.self, forKey: .languages_codes)
        } catch {
            //
        }
        
        do {
            self.carbon_footprint_from_known_ingredients_debug = try container.decode(Int.self, forKey: .carbon_footprint_from_known_ingredients_debug )
        } catch {
            do {
                let asString = try container.decode(String.self, forKey: .carbon_footprint_from_known_ingredients_debug)
                self.carbon_footprint_from_known_ingredients_debug = Int(asString)
            } catch {
                self.carbon_footprint_from_known_ingredients_debug = nil
            }
        }

        do {
            self.max_imgid = try container.decode(String.self, forKey: .max_imgid)
        } catch {
            do {
                let intCode = try container.decode(Int.self, forKey: .max_imgid)
                self.max_imgid = "\(intCode)"
            } catch {
                self.max_imgid = nil
            }
        }

        
        do {
            self.rev = try container.decode(Int.self, forKey: .rev)
        } catch {
            do {
                let asString = try container.decode(String.self, forKey: .rev)
                self.rev = Int(asString)
            } catch {
                self.rev = nil
            }
        }

        do {
            self.sortkey = try container.decode(Int.self, forKey: .sortkey)
        } catch {
            do {
                let asString = try container.decode(String.self, forKey: .sortkey)
                self.sortkey = Int(asString)
            } catch {
                self.sortkey = nil
            }
        }
        do {
            self.code = try container.decode(String.self, forKey: .code)
        } catch {
            do {
            let intCode = try container.decode(Int.self, forKey: .code)
                self.code = "\(intCode)"
            } catch {
                self.code = nil
            }
        }

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

        
        do {
            self.ingredients_n = try container.decode(Int.self, forKey: .ingredients_n)
         } catch {
            do {
                let asString = try container.decode(String.self, forKey: .ingredients_n)
                self.ingredients_n = Int(asString)
            } catch {
                self.ingredients_n = nil
            }
        }

        do {
            self.additives_n = try container.decode(Int.self, forKey: .additives_n)
        } catch {
            do {
                let asString = try container.decode(String.self, forKey: .additives_n)
                self.additives_n = Int(asString)
            } catch {
                self.additives_n = nil
            }
        }

        do {
            self.additives_old_n = try container.decode(Int.self, forKey: .additives_old_n)
        } catch {
            do {
                let asString = try container.decode(String.self, forKey: .additives_old_n)
                self.additives_old_n = Int(asString)
            } catch {
                self.additives_old_n = nil
            }
        }

        do {
            self.ingredients_from_or_that_may_be_from_palm_oil_n = try container.decode(Int.self, forKey: .ingredients_from_or_that_may_be_from_palm_oil_n)
        } catch {
            do {
                let asString = try container.decode(String.self, forKey: .ingredients_from_or_that_may_be_from_palm_oil_n)
                self.ingredients_from_or_that_may_be_from_palm_oil_n = Int(asString)
            } catch {
                self.ingredients_from_or_that_may_be_from_palm_oil_n = nil
            }
        }

        do {
            self.ingredients_from_palm_oil_n = try container.decode(Int.self, forKey: .ingredients_from_palm_oil_n)
        } catch {
            do {
                let asString = try container.decode(String.self, forKey: .ingredients_from_palm_oil_n)
                self.ingredients_from_palm_oil_n = Int(asString)
            } catch {
                self.ingredients_from_palm_oil_n = nil
            }
        }

        do {
            self.ingredients_that_may_be_from_palm_oil_n = try container.decode(Int.self, forKey: .ingredients_that_may_be_from_palm_oil_n)
        } catch {
            do {
                let asString = try container.decode(String.self, forKey: .ingredients_that_may_be_from_palm_oil_n)
                self.ingredients_that_may_be_from_palm_oil_n = Int(asString)
            } catch {
                self.ingredients_that_may_be_from_palm_oil_n = nil
            }
        }

        do {
            self.serving_quantity = try container.decode(Double.self, forKey: .serving_quantity)
        } catch {
            do {
                let asString = try container.decode(String.self, forKey: .serving_quantity)
                self.serving_quantity = Double(asString)
            } catch {
                self.serving_quantity = nil
            }
        }

        do {
            self.nova_group = try container.decode(String.self, forKey: .nova_group)
        } catch {
            do {
                let asDouble = try container.decode(Double.self, forKey: .nova_group)
                self.nova_group = "\(asDouble)"
            } catch {
                self.nova_group = nil
            }
        }

        do {
            self.nova_groups = try container.decode(String.self, forKey: .nova_groups)
        } catch {
            do {
                let asDouble = try container.decode(Double.self, forKey: .nova_groups)
                self.nova_groups = "\(asDouble)"
            } catch {
                self.nova_groups = nil
            }
        }

        do {
            self.novaDashgroup = try container.decode(String.self, forKey: .novaDashgroup)
        } catch {
            self.novaDashgroup = nil
        }

        do {
            self.novaDashgroup_100g = try container.decode(String.self, forKey: .novaDashgroup_100g)
        } catch {
            self.novaDashgroup_100g = nil
        }

        do {
            self.novaDashgroup_serving = try container.decode(String.self, forKey: .novaDashgroup_serving)
        } catch {
            self.novaDashgroup_serving = nil
        }
        // var product_quantity: String? = nil is handled in the child
        do {
            self.product_quantity = try container.decode(String.self, forKey: .product_quantity)
        } catch {
            do {
                let asInt = try container.decode(Int.self, forKey: .product_quantity)
                self.product_quantity = "\(asInt)"
            } catch {
                self.product_quantity = nil
            }
        }

        do {
            self.unknown_ingredients_n = try container.decode(Int.self, forKey: .unknown_ingredients_n)
        } catch {
            do {
                let asString = try container.decode(String.self, forKey: .unknown_ingredients_n)
                self.unknown_ingredients_n = Int(asString)
            } catch {
                self.unknown_ingredients_n = nil
            }
        }

        
        // try to extract all language specific fields
        for languageCode in languages_codes {
            for key in container.allKeys {
                if key.stringValue ==  KeyPreFix.ProductName + languageCode.key {
                    do {
                        let name = try container.decode(String.self, forKey: key)
                        product_names_[languageCode.key] = name
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
        self.languages_codes = [:]
        self.product_names_ = [:]
        self.generic_names_ = [:]
        self.ingredients_texts_ = [:]
        self.ingredients_texts_with_allergens_ = [:]
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
                     countries_tags: [String],
                     emb_codes_tags: [String],
                     expiration_date: String,
                     labels_tags: [String],
                     link: String,
                     manufacturing_places_tags: [String],
                     nutriments: OFFProductNutriments,
                     origins_tags: [String],
                     packaging_tags: [String],
                     purchase_places_tags: [String],
                     quantity: String,
                     serving_size: String,
                     stores_tags: [String],
                     traces_tags: [String] ) {
        
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
        self.ingredients_texts_ = ingredients
        self.labels = labels_tags.joined(separator: ",")
        self.labels_tags = labels_tags
        self.link = link
        self.manufacturing_places = manufacturing_places_tags.joined(separator: ",")
        self.manufacturing_places_tags = manufacturing_places_tags
        self.nutriments = nutriments
        self.origins = origins_tags.joined(separator: ",")
        self.origins_tags = origins_tags
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
        self.product_names_ = names
        self.generic_names_ = generic_names
        self.ingredients_texts_ = ingredients
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
            if let key = DetailedKeys(stringValue: KeyPreFix.ProductName + languageCode) {
                try container.encodeIfPresent(product_names_[languageCode], forKey: key)
            }
            if let key = DetailedKeys(stringValue: KeyPreFix.GenericName + languageCode) {
                try container.encodeIfPresent(generic_names_[languageCode], forKey: key)
            }
            if let key = DetailedKeys(stringValue: KeyPreFix.IngredientsText + languageCode) {
                try container.encodeIfPresent(ingredients_texts_[languageCode], forKey: key)
            }
        }
    }
}
