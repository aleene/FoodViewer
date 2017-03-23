//
//  ImageTypeCategory.swift
//  FoodViewer
//
//  Created by arnaud on 22/03/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

enum ImageTypeCategory: Int {
    case front = 0
    case ingredients
    case nutrition
    case unknown
    
    func description() -> String {
        switch self {
        case .front:
            return "front image"
        case .ingredients:
            return "ingredients image"
        case .nutrition:
            return "nutrition image"
        case .unknown:
            return "unknown image"
        }
    }

}
