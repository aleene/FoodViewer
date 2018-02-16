//
//  OFFProductJson.swift
//  FoodViewer
//
//  Created by arnaud on 06/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//
//  Inspired by https://benscheirman.com/2017/06/swift-json/

import Foundation

struct OFFProductJson : Codable {
    
    // if the loading has failed from some reason, there will no product defined
    let product: OFFProductDetailed?
    let status: Int
    let code: String
    let status_verbose: String
        
}

