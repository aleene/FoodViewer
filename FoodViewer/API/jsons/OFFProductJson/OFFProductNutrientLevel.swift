//
//  OFFProductNutrientLevel.swift
//  FoodViewer
//
//  Created by arnaud on 09/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation

enum OFFProductNutrientLevel: String, Codable {
    case en_fat_in_low_quantity = "en:fat-in-low-quantity"
    case en_fat_in_moderate_quantity = "en:fat-in-moderate-quantity"
    case en_fat_in_high_quantity = "en:fat-in-high-quantity"
    case en_salt_in_low_quantity = "en:salt-in-low-quantity"
    case en_salt_in_moderate_quantity = "en:salt-in-moderate-quantity"
    case en_salt_in_high_quantity = "en:salt-in-high-quantity"
    case en_saturated_fat_in_low_quantity = "en:saturated-fat-in-low-quantity"
    case en_saturated_fat_in_moderate_quantity = "en:saturated-fat-in-moderate-quantity"
    case en_saturated_fat_in_high_quantity = "en:saturated-fat-in-high-quantity"
    case en_sugars_in_low_quantity = "en:sugars-in-low-quantity"
    case en_sugars_in_moderate_quantity = "en:sugars-in-moderate-quantity"
    case en_sugars_in_high_quantity = "en:sugars-in-high-quantity"
}
