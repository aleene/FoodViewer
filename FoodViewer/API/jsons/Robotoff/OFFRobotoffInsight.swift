//
//  OFFRobotoffInsight.swift
//  FoodViewer
//
//  Created by arnaud on 18/10/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import Foundation

/*
Robotoff provides a simple API allowing consumers to fetch predictions and annotate them.
 
 Current insight types:
 - ingredient_spellcheck
 - packager_code
 - label
 - category
 - product_weight
 - expiration_date
 - brand
 - store
 - nutrient
 
 https://github.com/openfoodfacts/robotoff/blob/master/doc/api.md
 */
class OFFRobotoffInsight: Codable {
    
    var barcode: String? // "3336590106264"
    var confidence: Double // 1.0
    /// Only return predictions with products from a specific country (ex: en:france)
    var countries: [String]? // ["en:france"]
    var from_latent: String? // a2e30a29-9c7d-4424-81df-dfbe86752397
    /// ID of the insight
    var id: String? // "c68bcfc8-de08-491c-a9a9-e1ebd1080b48"
    /// the language of the question/value. 'en' by default.
    var lang: String? // "xx"
    var languages: [String]? // ["de","fr","it"]
    var logo_id: Int // 569155
    var rotation: String?
    var source_image: String? // "/333/659/010/6264/2.jpg"
    ///  the type of insight. If not provided, an insight from any type will be returned.
    var type: String? //"label",
}
