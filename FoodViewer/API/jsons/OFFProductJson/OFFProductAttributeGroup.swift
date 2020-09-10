//
//  OFFProductAttributeGroup.swift
//  FoodViewer
//
//  Created by arnaud on 09/09/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import Foundation

struct OFFProductAttributeGroup: Codable {
    let id: String
    let attributes: [OFFProductAttribute]
    let name: String
}
