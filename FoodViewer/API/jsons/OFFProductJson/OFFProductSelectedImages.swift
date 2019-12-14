//
//  OFFProductSelectedImages.swift
//  FoodViewer
//
//  Created by arnaud on 09/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation

struct OFFProductSelectedImages: Codable {
    let front: OFFProductSelectedImagesSizes?
    let nutrition: OFFProductSelectedImagesSizes?
    let ingredients: OFFProductSelectedImagesSizes?
}

struct OFFProductSelectedImagesSizes: Codable {
    // The keys are het languageCodes
    let display: [String:URL]
    let small: [String:URL]
    let thumb: [String:URL]
}
