//
//  OFFProductAttribute.swift
//  FoodViewer
//
//  Created by arnaud on 09/09/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import Foundation

struct OFFProductAttribute: Codable {
    let id: String
    let title: String?
    let name: String
    let description_short: String
    let description: String
    let match: Double
    let status: String
}
