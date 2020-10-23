//
//  ImageTypeCategory.swift
//  FoodViewer
//
//  Created by arnaud on 22/03/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

enum ImageTypeCategory: Int {
    case general = 0
    case front
    case ingredients
    case nutrition
    case packaging
    
    // These decriptions are used in the deselect/update API's to OFF
    var description: String {
        switch self {
        case .front:
            return "front"
        case .ingredients:
            return "ingredients"
        case .nutrition:
            return "nutrition"
        case .packaging:
            return "packaging"
        case .general:
            return "general"
        }
    }

    static var list: [ImageTypeCategory] {
        return [.front, .ingredients, .nutrition, .packaging]
    }
    
    static func type(for string: String) -> ImageTypeCategory {
        switch string {
        case ImageTypeCategory.front.description:
            return .front
        case ImageTypeCategory.ingredients.description:
            return .ingredients
        case ImageTypeCategory.nutrition.description:
            return .nutrition
        case ImageTypeCategory.packaging.description:
            return .packaging
        case ImageTypeCategory.general.description:
            return .general
        default:
            return .general
        }
    }
}
