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
    var base: String? = nil // i.e. "energy-kj
    var per100g: String? = nil // i.e. energy-kj_100g
    var serving: String? = nil // i.e. energy-kj_serving
    var value: String? = nil // i.e. energy-kj_value
    var label: String? = nil
    var unit: String? = nil // i.e. energy-kj_unit. The unit refers to the value.
    
    var isEmpty: Bool {
        return base == nil &&
            per100g == nil &&
            serving == nil &&
            value == nil &&
            label == nil &&
            unit == nil
    }
    
    init() {
        base = nil
        per100g = nil
        serving = nil
        value = nil
        label = nil
        unit = nil
    }
    
    init(base: String?, per100g: String?, serving: String?, value: String?, label: String?, unit: String?) {
        self.init()
        self.base = base
        self.per100g = per100g
        self.serving = serving
        self.value = value
        self.label = label
        self.unit = unit
    }
}
