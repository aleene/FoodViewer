//
//  NutritionFactItem.swift
//  FoodViewer
//
//  Created by arnaud on 10/04/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

struct NutritionFactItem {
    var itemName: String? = nil
    var standardValue: String? = nil
    var standardValueUnit: String? = nil
    var servingValue: String? = nil
    var servingValueUnit: String? = nil
    
    func valid() -> Bool {
        return standardValue != nil && !standardValue!.isEmpty
    }
}
