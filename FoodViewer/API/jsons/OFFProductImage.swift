//
//  OFFProductImage.swift
//  FoodViewer
//
//  Created by arnaud on 09/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation

class OFFProductImage: Codable {
    let geometry: String?
    //let imgid: String? or Int?
    let normalize: String?
    // let rev: String? Handled in PFFProductImageDetailed
    let sizes: OFFProductImageSizes
    let uploader: String?
    // let uploaded_t: Int? Handled in PFFProductImageDetailed
    let white_magic: String?
}

struct OFFProductImageSizes: Codable {
    let s100: OFFProductImageSize
    let s400: OFFProductImageSize
    let full: OFFProductImageSize
    
    enum CodingKeys: String, CodingKey {
        case s100 = "100"
        case s400 = "400"
        case full
    }
}
