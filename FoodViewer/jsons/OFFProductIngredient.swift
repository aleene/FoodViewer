//
//  OFFProductIngredient.swift
//  FoodViewer
//
//  Created by arnaud on 09/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation

struct OFFProductIngredient: Codable {
    let id: String
    let text: String
    let rank: Int?
    let vegan: String
    let vegetarian: String
}
