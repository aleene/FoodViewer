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
    "adjustments":{
        "origins_of_ingredients":{
            "aggregated_origins":[
                {
                "origin":"en:thailand",
                "percent":100
                }
            ],
            "epi_score":0,
            "epi_value":-5,
            "origins_from_origins_field":["en:thailand"],
            "transportation_scores":{"ad":19,"al":33,"at":8,"ax":4,"ba":11,"be":12,"bg":13,"ch":9,"cy":37,"cz":0,"de":12,"dk":0,"dz":9,"ee":7,"eg":33,"es":25,"fi":7,"fo":3,"fr":0,"gg":0,"gi":27,"gr":37,"hr":24,"hu":4,"ie":17,"il":33,"im":0,"is":0,"it":16,"je":0,"lb":37,"li":11,"lt":0,"lu":3,"lv":8,"ly":34,"ma":3,"mc":31,"md":22,"me":29,"mk":20,"mt":34,"nl":12,"no":12,"pl":0,"ps":41,"pt":16,"ro":23,"rs":10,"se":0,"si":27,"sj":0,"sk":0,"sm":10,"sy":24,"tn":33,"tr":0,"ua":33,"uk":7,"us":0,"va":1,"world":0,"xk":19},
            "transportation_values":{"ad":3,"al":5,"at":1,"ax":1,"ba":2,"be":2,"bg":2,"ch":1,"cy":6,"cz":0,"de":2,"dk":0,"dz":1,"ee":1,"eg":5,"es":4,"fi":1,"fo":0,"fr":0,"gg":0,"gi":4,"gr":6,"hr":4,"hu":1,"ie":3,"il":5,"im":0,"is":0,"it":2,"je":0,"lb":6,"li":2,"lt":0,"lu":0,"lv":1,"ly":5,"ma":0,"mc":5,"md":3,"me":4,"mk":3,"mt":5,"nl":2,"no":2,"pl":0,"ps":6,"pt":2,"ro":3,"rs":2,"se":0,"si":4,"sj":0,"sk":0,"sm":2,"sy":4,"tn":5,"tr":0,"ua":5,"uk":1,"us":0,"va":0,"world":0,"xk":3},
            "values":{"ad":-2,"al":0,"at":-4,"ax":-4,"ba":-3,"be":-3,"bg":-3,"ch":-4,"cy":1,"cz":-5,"de":-3,"dk":-5,"dz":-4,"ee":-4,"eg":0,"es":-1,"fi":-4,"fo":-5,"fr":-5,"gg":-5,"gi":-1,"gr":1,"hr":-1,"hu":-4,"ie":-2,"il":0,"im":-5,"is":-5,"it":-3,"je":-5,"lb":1,"li":-3,"lt":-5,"lu":-5,"lv":-4,"ly":0,"ma":-5,"mc":0,"md":-2,"me":-1,"mk":-2,"mt":0,"nl":-3,"no":-3,"pl":-5,"ps":1,"pt":-3,"ro":-2,"rs":-3,"se":-5,"si":-1,"sj":-5,"sk":-5,"sm":-3,"sy":-1,"tn":0,"tr":-5,"ua":0,"uk":-4,"us":-5,"va":-5,"world":-5,"xk":-2}
        },
        "packaging": {
            "non_recyclable_and_non_biodegradable_materials":0,
            "packagings":[
                {"ecoscore_material_score":0,
                "ecoscore_shape_ratio":1,
                "material":"en:unknown",
                "shape":"xx:cellophane"},
                {
                "ecoscore_material_score":0,
                "ecoscore_shape_ratio":1,
                "material":"en:unknown",
                "shape":"en:container"}
            ],
            "score":-100,
            "value":-15,
            "warning":"unscored_shape"
        },
        "production_system":{
            "labels":[],
            "value":0,
            "warning":"no_label"
        },
        "threatened_species":{}
    },
    "agribalyse":{
        "warning":"missing_agribalyse_match"
    },
    "missing":{
        "agb_category":1,
        "labels":1,
        "packagings":1
    },
    "missing_agribalyse_match_warning":1,
    "status":"unknown"
}
*/
class OFFProductEcoscoreData: Codable {
    
    var adjustments: OFFProductEcoscoreDataAdjustments? = nil
    var agribalyse: OFFProductEcoscoreDataAgribalyse? = nil
    var grade: String? = nil
    var missing: OFFProductEcoscoreDataMissing? = nil
    var missing_agribalyse_match_warning: Int? = nil
    var score: Double? = nil
    var status: String? = nil // "known" or "unknown"

}

class OFFProductEcoscoreDataMissing: Codable {
    var agb_category: Int? = nil
}

class OFFProductEcoscoreDataAdjustments: Codable {
    var origins_of_ingredients: OFFProductEcoscoreDataAdjustmentsOriginsOfIngredientsDetailed? = nil
    var production_system: OFFProductEcoscoreDataAdjustmentsProductionSystem? = nil
    var packaging: OFFProductEcoscoreDataAdjustmentsPackaging? = nil
    var threatened_species: OFFProductEcoscoreDataThreatenedSpecies? = nil
}

class OFFProductEcoscoreDataThreatenedSpecies: Codable {
}

class OFFProductEcoscoreDataAgribalyse: Codable {
    var agribalyse_ef_total: String? = nil
    var agribalyse_food_name_en: String? = nil
    var agribalyse_food_code: String? = nil
    var agribalyse_food_name_fr: String? = nil
    var agribalyse_proxy_food_code: String? = nil
    var code: String? = nil
    // var co2_agriculture: String? = nil
    // var co2_consumption: String? = nil
    //var co2_distribution: Double? = nil
    //var co2_packaging: Double? = nil
    //var co2_processing: Double? = nil
    //var co2_total: Double? = nil
    //var co2_transportation: Double? = nil
    var dqr: String? = nil
    //var ef_agriculture: String? = nil
    //var ef_consumption: String? = nil
    //var ef_distribution: Double? = nil
    //var ef_packaging: Double? = nil
    //var ef_processing: Double? = nil
    //var ef_total: Double? = nil
    //var ef_transportation: Double? = nil
    var name_en: String? = nil
    var name_fr: String? = nil
    var score: Double? = nil
    var warning: String? = nil
}

/// Class to intercept json keys that are not always encoded in the same way.

class OFFProductEcoscoreDataAgribalyseDetailed: OFFProductEcoscoreDataAgribalyse {
    struct DetailedKeys : CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        var intValue: Int? { return nil }
        init?(intValue: Int) { return nil }
        
        static let co2_agriculture = DetailedKeys(stringValue: "co2_agriculture")!
        static let co2_total = DetailedKeys(stringValue: "co2_total")!
        static let co2_transportation = DetailedKeys(stringValue: "co2_transportation")!
        static let co2_consumption = DetailedKeys(stringValue: "co2_consumption")!
        static let co2_distribution = DetailedKeys(stringValue: "co2_distribution")!
        static let co2_packaging = DetailedKeys(stringValue: "co2_packaging")!
        static let co2_processing = DetailedKeys(stringValue: "co2_processing")!
        static let ef_agriculture = DetailedKeys(stringValue: "ef_agriculture")!
        static let ef_consumption = DetailedKeys(stringValue: "ef_consumption")!
        static let ef_distribution = DetailedKeys(stringValue: "ef_distribution")!
        static let ef_packaging = DetailedKeys(stringValue: "ef_packaging")!
        static let ef_processing = DetailedKeys(stringValue: "ef_processing")!
        static let ef_total = DetailedKeys(stringValue: "ef_total")!
        static let ef_transportation = DetailedKeys(stringValue: "ef_transportation")! 
    }

    var co2_agriculture: Double? = nil
    var co2_total: Double? = nil
    var co2_transportation: Double? = nil
    var co2_consumption: Double? = nil
    var co2_distribution: Double? = nil
    var co2_packaging: Double? = nil
    var co2_processing: Double? = nil
    var ef_agriculture: Double? = nil
    var ef_consumption: Double? = nil
    var ef_distribution: Double? = nil
    var ef_packaging: Double? = nil
    var ef_processing: Double? = nil
    var ef_total: Double? = nil
    var ef_transportation: Double? = nil

    required init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: DetailedKeys.self)
                
        self.co2_agriculture = container.forceDouble(key: .co2_agriculture)
        self.co2_total = container.forceDouble(key: .co2_total)
        self.co2_transportation = container.forceDouble(key: .co2_transportation)
        self.co2_consumption = container.forceDouble(key: .co2_consumption)
        self.co2_distribution = container.forceDouble(key: .co2_distribution)
        self.co2_packaging = container.forceDouble(key: .co2_packaging)
        self.co2_processing = container.forceDouble(key: .co2_processing)
        self.ef_agriculture = container.forceDouble(key: .ef_agriculture)
        self.ef_consumption = container.forceDouble(key: .ef_consumption)
        self.ef_distribution = container.forceDouble(key: .ef_distribution)
        self.ef_packaging = container.forceDouble(key: .ef_packaging)
        self.ef_processing = container.forceDouble(key: .ef_processing)
        self.ef_total = container.forceDouble(key: .ef_total)
        self.ef_transportation = container.forceDouble(key: .ef_transportation)

        try super.init(from: decoder)
    }

}

class OFFProductEcoscoreDataAdjustmentsOriginsOfIngredients: Codable {
    //var transportation_value: Double? = nil
    var origins_from_origins_field: [String]? = nil
    //var transportation_score: Int? = nil
    //var epi_value: Int? = nil
    //var epi_score: Int? = nil
    var aggregated_origins: [OFFProductEcoscoreDataAdjustmentsOriginsOfIngredientsAggregatedOrigins]? = nil
    var value: Double? = nil
    //var transportation_scores:
    //var transportation_values:
    //var values:
}

class OFFProductEcoscoreDataAdjustmentsOriginsOfIngredientsAggregatedOrigins: Codable {
    var origin: String? = nil
    var percent: Double? = nil
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
    }

    var epi_value: Double? = nil
    var epi_score: Double? = nil
    var transportation_score: Double? = nil
    var transportation_value: Double? = nil

    required init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: DetailedKeys.self)
                
        self.epi_score = container.forceDouble(key: .epi_score)
        self.epi_value = container.forceDouble(key: .epi_value)
            
        try super.init(from: decoder)
    }

}

class OFFProductEcoscoreDataAdjustmentsProductionSystem: Codable {
    var value: Double? = nil
    var label: String? = nil
    //var labels: [???]? = nil
    var warning: String? = nil
}

class OFFProductEcoscoreDataAdjustmentsPackaging: Codable {
    var value: Double? = nil
    var score: Double? = nil
    var warning: String? = nil
    var non_recyclable_and_non_biodegradable_materials: Int? = nil
    var packagings: [OFFProductEcoscoreDataAdjustmentsPackagingShapeDetailed]? = nil
}

class OFFProductEcoscoreDataAdjustmentsPackagingShape: Codable {
    var shape: String? = nil
    var material: String? = nil
    var ecoscore_counted: Int? = nil
    var ecoscore_material_warning: String? = nil
    //var ecoscore_material_score: Int? = nil
    //var ecoscore_shape_ratio: Int? = nil
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

