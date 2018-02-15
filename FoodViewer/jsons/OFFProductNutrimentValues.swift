//
//  OFFProductNutrimentValues.swift
//  FoodViewer
//
//  Created by arnaud on 10/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation

struct OFFProductNutrimentValues {
    
    // These can be let's, however the json does provide them only piece by piece
    var base: String?
    var per100g: String?
    var serving: String?
    var value: String?
    var label: String?
    var unit: String?
    
    var isEmpty: Bool {
        return base == nil &&
            per100g == nil &&
            serving == nil &&
            value == nil &&
            label == nil &&
            unit == nil
    }
}
