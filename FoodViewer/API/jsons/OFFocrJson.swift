//
//  OFFocrJson.swift
//  FoodViewer
//
//  Created by arnaud on 15/11/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import Foundation

class OFFOCRJson : Codable {
    
    var ingredients_text_from_image: String?
    var ingredients_text_from_image_orig: String?
    var status: Int? // "0" when found, "1" when error
    
}
