//
//  OFFProductForestFootPrintDataIngredientsType.swift
//  FoodViewer
//
//  Created by arnaud on 28/11/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import Foundation
/*
 "type":{
     "name":"Oeufs Importés",
     "soy_yield":"0.3",
     "deforestation_risk":"0.68",
     "soy_feed_factor":"0.035"
 },
 */
class OFFProductForestFootPrintDataIngredientsType: Codable {
    
    // var deforestation_risk: String? = nil decoded in OFFProductForestFootPrintDataIngredientsType
    var name: String? = nil
    // var soy_feed_factor: String? = nil decoded in OFFProductForestFootPrintDataIngredientsTypeDetailed
    // var soy_yield: String? = nil  decoded in OFFProductForestFootPrintDataIngredientsTypeDetailed

}

