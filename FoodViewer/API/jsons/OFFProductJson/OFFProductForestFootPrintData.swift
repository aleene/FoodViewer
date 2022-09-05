//
//  OFFProductForestFootPrintData.swift
//  FoodViewer
//
//  Created by arnaud on 28/11/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import Foundation
/*
 "forest_footprint_data":{
     "footprint_per_kg": 0.00361958333333333,
     "ingredients":[
         {
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
             "processing_factor":1
         }
     ]
 },

 Ingredients requiring soy
 L'empreinte forêt est calculée en prenant en compte les ingrédients dont l'élaboration nécessite du soja dont la culture est liée à la déforestation.

 Ingredients requiring soy:
 Ingredient    Type    % in product    Processing factor
 (% of food after processing)    Soy feed factor
 (kg of soy per kg of food)    Soy yield
 (kg of soy per m²)    Deforestation risk
 (%)    Forest footprint
 (m² per kg of food)
 Free range egg yolk    Oeufs Importés    4.56    100    0.035    0.3    68    0.00
 Total forest footprint
 0.00 m² per kg of food

 */
class OFFProductForestFootPrintData: Codable {
    
    var footprint_per_kg: Double? = nil
    var ingredients: [OFFProductForestFootPrintDataIngredientsDetailed]? = nil

}
