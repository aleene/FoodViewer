//
//  OFFJsonResult.swift
//  FoodViewer
//
//  Created by arnaud on 12/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation

struct OFFJsonResult : Codable {
    
    // if the loading has failed from some reason, there will no product defined
    let status: Int
    let code: String
    let status_verbose: String
    
    enum CodingKeys: String, CodingKey {
        case status
        case code
        case status_verbose
    }
    
}

