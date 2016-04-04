//
//  Status.swift
//  FoodViewer
//
//  Created by arnaud on 03/04/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

struct Status: CustomStringConvertible {
    var value = false
    var text = ""
    
    var description: String {
        get {
            return text
        }
    }

}