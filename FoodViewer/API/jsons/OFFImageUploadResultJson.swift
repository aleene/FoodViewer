//
//  OFFImageUploadResultJson.swift
//  FoodViewer
//
//  Created by arnaud on 13/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation

class OFFImageUploadResultJson : Codable {
    
    var status: String? = nil
    // Has value "status ok" if the upload succeeded
    var imagefield: String? = nil // "general_6"
    // Encodes the image type and numer or language
    
}
