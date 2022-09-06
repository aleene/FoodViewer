//
//  OFFProductImageSize.swift
//  FoodViewer
//
//  Created by arnaud on 16/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation

class OFFProductImageSize: Codable {
    
    var w: Int? = nil
    var h: Int? = nil
    
    enum CodingKeys: String, CodingKey {
        case w
        case h
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.w = container.forceInt(key: .w)
        self.h = container.forceInt(key: .h)
    }

}
