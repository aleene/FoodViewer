//
//  OFFProductNutrimentValues.swift
//  FoodViewer
//
//  Created by arnaud on 10/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation

struct OFFProductNutrimentValues {
    let base: String?
    let per100g: String?
    let serving: String?
    let value: String?
    let label: String?
    let unit: String?
    
    var isEmpty: Bool {
        return base == nil &&
            per100g == nil &&
            serving == nil &&
            value == nil &&
            label == nil &&
            unit == nil
    }
}
