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
    var agribalyse_proxy_food_code: String? = nil
    var code: String? = nil
    var co2_agriculture: String? = nil
    var co2_consumption: String? = nil
    var co2_distribution: String? = nil
    var co2_packaging: String? = nil
    var co2_processing: String? = nil
    var co2_total: String? = nil
    var co2_transportation: String? = nil
    var dqr: String? = nil
    var ef_agriculture: String? = nil
    var ef_consumption: String? = nil
    var ef_distribution: String? = nil
    var ef_packaging: String? = nil
    var ef_processing: String? = nil
    var ef_total: String? = nil
    var ef_transportation: String? = nil
    var name_en: String? = nil
    var name_fr: String? = nil
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
        static let transportation_value = DetailedKeys(stringValue: "transportation_value")!
    }

    var epi_value: Double? = nil
    var epi_score: Double? = nil
    var transportation_score: Double? = nil
    var transportation_value: Double? = nil

    required init(from decoder: Decoder) throws {
        /*

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
*/
        let container = try decoder.container(keyedBy: DetailedKeys.self)
                
        self.epi_score = container.forceDouble(key: .epi_score)
        self.epi_value = container.forceDouble(key: .epi_value)
        self.transportation_score = container.forceDouble(key: .transportation_score)
        self.transportation_value = container.forceDouble(key: .transportation_value)
            
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
}


class OFFProductEcoscoreDataAdjustmentsPackagingShapeDetailed: OFFProductEcoscoreDataAdjustmentsPackagingShape {
    
    enum CodingKeys: String, CodingKey {
        case ecoscore_material_score
        case ecoscore_shape_ratio
    }

    var ecoscore_material_score: Double? = nil
    var ecoscore_shape_ratio: Double? = nil

    required init(from decoder: Decoder) throws {

        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            ecoscore_shape_ratio = container.forceDouble(key: .ecoscore_shape_ratio)
            ecoscore_material_score = container.forceDouble(key: .ecoscore_material_score)
        } catch {
            print("OFFProductEcoscoreDataAdjustmentsPackagingShapeDetailed: all decoding failed")
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
                    print("KeyedDecodingContainer:forceDouble: \(key) is not convertable")
                    return nil
                }
            }
        }
    }

    func forceInt(key: K) -> Int? {
        do {
            return try decode(Int.self, forKey: key )
        } catch {
            do {
                let asDouble = try decode(Double.self, forKey: key)
                return Int(asDouble)
            } catch {
                do {
                    let asString = try decode(String.self, forKey: key)
                    return Int(asString)
                } catch {
                    print("KeyedDecodingContainer:forceInt: \(key) is not convertable")
                    return nil
                }
            }
        }
    }

    func forceString(key: K) -> String? {
        do {
            return try decode(String.self, forKey: key)
        } catch {
            do {
                print("KeyedDecodingContainer:forceString: \(key) is not a String")
                let name = try decode(Float.self, forKey: key)
                return "\(name)"
            } catch {
                print("KeyedDecodingContainer:forceString: \(key) is not a Float")
                do {
                    let name = try decode(Int.self, forKey: key)
                    return "\(name)"
                } catch {
                    print("KeyedDecodingContainer:forceString: \(key) is not an Int")
                    return nil
                }
            }
        }
    }

}
