//
//  NatriumChloride.swift
//  FoodViewer
//
//  Created by arnaud on 07/04/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

enum NatriumChloride {
    case Salt
    case Sodium
    case Both
    
    func description() -> String {
        switch self {
        case .Salt: return "Salt"
        case .Both: return "Both"
        case .Sodium: return "Sodium"
        }
    }
    
    func index() -> Int {
        switch self {
        case .Salt: return 0
        case .Both: return 1
        case .Sodium: return 2
        }
    }
}
