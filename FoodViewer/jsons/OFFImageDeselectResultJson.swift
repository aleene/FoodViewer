//
//  OFFImageDeselectResultJson.swift
//  FoodViewer
//
//  Created by arnaud on 12/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation

class OFFImageDeselectResultJson : Codable {
    
    var status: String
    var status_code: Int?
    var imagefield: String
/*
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case status_code = "status_code"
        case imagefield = "imagefield"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        for key in container.allKeys {
            print("OFFImageDeselectResultJson", key)
        }
        status = try container.decode(String.self, forKey: .status)
        status_code = try container.decode(Int.self, forKey: .status_code)
        imagefield = try container.decode(String.self, forKey: .imagefield)
    }
 */
}
