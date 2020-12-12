//
//  OFFProductEcoscoreData.swift
//  FoodViewer
//
//  Created by arnaud on 09/12/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import Foundation
/*
"ecoscore_data":{
    "score":71.462822438932,
    "grade":"b",
    "adjustments":{
        "threatened_species":{},
        "origins_of_ingredients":{
            "transportation_value":0,
            "origins_from_origins_field":["en:unknown"],
            "transportation_score":0,
            "epi_value":-5,
            "epi_score":0,
            "aggregated_origins":[["en:unknown",100]],
            "value":-5
        },
        "production_system":{
            "value":10,
            "label":"en:fairtrade-international"
        },
        "packaging":{
            "value":-10,
            "score":0,"packagings":[{
                "shape":"en:pot",
                "ecoscore_counted":1,
                "ecoscore_material_warning":"unspecified_material",
                "ecoscore_shape_ratio":"1",
                "ecoscore_material_score":0
            }
            ]
        }
    }
 */
class OFFProductEcoscoreData: Codable {
    
    var adjustments: OFFProductEcoscoreDataAdjustments? = nil
    var agribalyse: OFFProductEcoscoreDataAgrybalyse? = nil
    var grade: String? = nil
    var missing: OFFProductEcoscoreDataMissing? = nil
    var score: Double? = nil
    var status: String? = nil // "known" or "unknown"

}

class OFFProductEcoscoreDataMissing: Codable {
    var agb_category: Int? = nil
}

class OFFProductEcoscoreDataAdjustments: Codable {
    //var threatened_species: OFFProductEcoscoreDataAdjustmentsThreatenedSpecies? = nil
    var origins_of_ingredients: OFFProductEcoscoreDataAdjustmentsOriginsOfIngredientsDetailed? = nil
    var production_system: OFFProductEcoscoreDataAdjustmentsProductionSystem? = nil
    var packaging: OFFProductEcoscoreDataAdjustmentsPackaging? = nil
}

class OFFProductEcoscoreDataAgrybalyse: Codable {
    var agribalyse_ef_total: String? = nil
    var agribalyse_food_name_en: String? = nil
    var agribalyse_food_code: String? = nil
    var agribalyse_food_name_fr: String? = nil
    var score: Double? = nil
}

class OFFProductEcoscoreDataAdjustmentsOriginsOfIngredients: Codable {
    //var transportation_value: Double? = nil
    var origins_from_origins_field: [String]? = nil
    //var transportation_score: Int? = nil
    //var epi_value: Int? = nil
    //var epi_score: Double? = nil
    // var aggregated_origins: [["en:unknown", 100]],
    var value: Double? = nil
}

class OFFProductEcoscoreDataAdjustmentsOriginsOfIngredientsDetailed: OFFProductEcoscoreDataAdjustmentsOriginsOfIngredients {
    
    struct DetailedKeys : CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        var intValue: Int? { return nil }
        init?(intValue: Int) { return nil }
        
        static let epi_value = DetailedKeys(stringValue: "epi_value")!
        static let epi_score = DetailedKeys(stringValue: "epi_score")!
        static let transportation_score = DetailedKeys(stringValue: "transportation_score")!
        static let transportation_value = DetailedKeys(stringValue: "transportation_score")!
    }

    var epi_value: Double? = nil
    var epi_score: Double? = nil
    var transportation_score: Double? = nil
    var transportation_value: Double? = nil

    required init(from decoder: Decoder) throws {
        
        func forceInt(key: DetailedKeys) -> Int? {
            do {
                return try container.decode(Int.self, forKey: key )
            } catch {
                do {
                    let asDouble = try container.decode(Double.self, forKey: key)
                    return Int(asDouble)
                } catch {
                    return nil
                }
            }
        }
        
        func forceDouble(key: DetailedKeys) -> Double? {
            do {
                return try container.decode(Double.self, forKey: key )
            } catch {
                do {
                    let asInt = try container.decode(Int.self, forKey: key)
                    return Double(asInt)
                } catch {
                    do {
                        let asString = try container.decode(String.self, forKey: key)
                        return Double(asString)
                    } catch {
                        return nil
                    }
                }
            }
        }

        let container = try decoder.container(keyedBy: DetailedKeys.self)
                
        self.epi_score = forceDouble(key: .epi_score)
        self.epi_value = forceDouble(key: .epi_value)
        self.transportation_score = forceDouble(key: .transportation_score)
        self.transportation_value = forceDouble(key: .transportation_value)
            
        try super.init(from: decoder)
    }

}

class OFFProductEcoscoreDataAdjustmentsOriginsOfIngredientsAggregatedOrigins : Codable {
    
}

class OFFProductEcoscoreDataAdjustmentsProductionSystem: Codable {
    var value: Double? = nil
    var label: String? = nil
}

class OFFProductEcoscoreDataAdjustmentsPackaging: Codable {
    var value: Double? = nil
    var score: Double? = nil
    var packagings: [OFFProductEcoscoreDataAdjustmentsPackagingShapeDetailed]? = nil
}

class OFFProductEcoscoreDataAdjustmentsPackagingShape: Codable {
    var shape: String? = nil
    var material: String? = nil
    var ecoscore_counted: Int? = nil
    var ecoscore_material_warning: String? = nil
    var ecoscore_shape_ratio: String? = nil
    //var ecoscore_material_score: String? = nil
}


class OFFProductEcoscoreDataAdjustmentsPackagingShapeDetailed: OFFProductEcoscoreDataAdjustmentsPackagingShape {
    
    /*
    struct DetailedKeys : CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        var intValue: Int? { return nil }
        init?(intValue: Int) { return nil }
        
        static let ecoscore_material_score = DetailedKeys(stringValue: "ecoscore_material_score")!
    }
 */

    enum CodingKeys: String, CodingKey {
        case ecoscore_material_score
    }

    var ecoscore_material_score: Double? = nil
    
    required init(from decoder: Decoder) throws {
        /*
        func forceDouble(key: CodingKeys) -> Double? {
            do {
                return try container.decode(Double.self, forKey: key )
            } catch {
                do {
                    let asInt = try container.decode(Int.self, forKey: key)
                    return Double(asInt)
                } catch {
                    do {
                        let asString = try container.decode(String.self, forKey: key)
                        return Double(asString)
                    } catch {
                        return nil
                    }
                }
            }
        }
        */
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            ecoscore_material_score = container.forceDouble(key: .ecoscore_material_score)
            
        } catch {
            print("OFFProductEcoscoreDataAdjustmentsPackagingShapeDetailed: decoding failed")
        }

        try super.init(from: decoder)
    }

}

extension KeyedDecodingContainer {
    
    func forceDouble(key: K) -> Double? {
        do {
            return try decode(Double.self, forKey: key )
        } catch {
            do {
                let asInt = try decode(Int.self, forKey: key)
                return Double(asInt)
            } catch {
                do {
                    let asString = try decode(String.self, forKey: key)
                    return Double(asString)
                } catch {
                    return nil
                }
            }
        }
    }

}
