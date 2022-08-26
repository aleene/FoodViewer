//
//  ProductPair.swift
//  FoodViewer
//
//  Created by arnaud on 29/11/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import Foundation

struct ForestFootprintIngredientType {
    var name: String? = nil
    var soyYield: String? = nil
    var deforestationRisk: String? = nil
    var soyFeedFactor: String? = nil
}

struct ForestFootprintIngredient {
    var conditions: [String] = []
    var tagID: String? = nil
    var type: ForestFootprintIngredientType? = nil
    var matchingTagID: String? = nil
    var tagType: String? = nil
    var footprintPerKg: Double? = nil
    var percent: Double? = nil
    var percentEstimate: Double? = nil
    var processingFactor: String? = nil
}

struct ForestFootprint {
    var footprintPerKg: Double? = nil
    var ingredients: [ForestFootprintIngredient] = []
    
}
