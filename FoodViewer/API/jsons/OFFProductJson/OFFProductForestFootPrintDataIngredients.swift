//
//  OFFProductForestFootPrintDataIngredients.swift
//  FoodViewer
//
//  Created by arnaud on 28/11/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import Foundation
/*
 "conditions_tags":[],
 "tag_id":"en:free-range-egg-yolk",
 "matching_tag_id":"en:egg",
 "type":{
     "name":"Oeufs Importés",
     "soy_yield":"0.3",
     "deforestation_risk":"0.68",
     "soy_feed_factor":"0.035"
 },
 "tag_type":"ingredients",
 "footprint_per_kg":0.00361958333333333,
 "percent":4.5625,
 "percent_estimate":4.5625,
 "processing_factor":"1"

 */
class OFFProductForestFootPrintDataIngredients: Codable {
    
    //var conditions_tags: [String]? = nil
    var footprint_per_kg: Double? = nil
    var matching_tag_id: String? = nil
    // var percent: Double? = nil
    var percent_estimate: Double? = nil
    var processing_factor: String? = nil
    var tag_id: String? = nil
    var tag_type: String? = nil
    var type: OFFProductForestFootPrintDataIngredientsType? = nil

}

class OFFProductForestFootPrintDataIngredientsDetailed: OFFProductForestFootPrintDataIngredients {
    
    struct DetailedKeys : CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        var intValue: Int? { return nil }
        init?(intValue: Int) { return nil }
        
        static let percent = DetailedKeys(stringValue: "percent")!
    }

    var percent: Double? = nil
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DetailedKeys.self)
                
        do {
            self.percent = try container.decode(Double.self, forKey: .percent )
        } catch {
            do {
                let asString = try container.decode(String.self, forKey: .percent)
                self.percent = Double(asString)
            } catch {
                self.percent = nil
            }
        }
        
        try super.init(from: decoder)
    }

}
