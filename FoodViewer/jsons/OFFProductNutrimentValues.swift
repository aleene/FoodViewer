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
    var base: String? = nil
    var per100g: String? = nil
    var serving: String? = nil
    var value: String? = nil
    var label: String? = nil
    var unit: String? = nil
    
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
