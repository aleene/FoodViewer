//
//  OFFProductImage.swift
//  FoodViewer
//
//  Created by arnaud on 09/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation

struct OFFProductImage: Codable {
    let geometry: String?
    let imgid: String?
    let normalize: String?
    let rev: String?
    let sizes: OFFProductImageSizes
    let uploader: String?
    //let uploaded_t: Int?
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

struct OFFProductImageSize: Codable {
    let w: Int
    let h: Int
}
