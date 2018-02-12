//
//  OFFProductNutrientLevels.swift
//  FoodViewer
//
//  Created by arnaud on 09/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation


struct OFFProductNutrientLevels: Codable {
    let fat: OFFProductNutrientLevelValue?
    let salt: OFFProductNutrientLevelValue?
    let saturated_fat: OFFProductNutrientLevelValue?
    let sugars: OFFProductNutrientLevelValue?
    
    enum CodingKeys: String, CodingKey {
        case fat
        case salt
        case saturated_fat = "saturated-fat"
        case sugars
    }
}
