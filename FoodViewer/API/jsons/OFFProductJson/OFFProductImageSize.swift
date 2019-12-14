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
        
        do {
            self.w = try container.decode(Int.self, forKey: .w)
        } catch {
            let wString = try container.decode(String.self, forKey: .w)
            self.w = Int.init(wString)
        }
        
        do {
            self.w = try container.decode(Int.self, forKey: .h)
        } catch {
            let hString = try container.decode(String.self, forKey: .h)
            self.h = Int.init(hString)
        }
    }

}
