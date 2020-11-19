//
//  ImageTypeCategory.swift
//  FoodViewer
//
//  Created by arnaud on 22/03/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

enum ImageTypeCategory: Equatable, Hashable {
    
    static func ==(lhs: ImageTypeCategory, rhs: ImageTypeCategory) -> Bool {
        switch lhs {
        case .front(let lhsValue):
            switch rhs {
            case .front(let rhsValue):
                return lhsValue == rhsValue
            default:
                return false
            }
        case .ingredients(let lhsValue):
            switch rhs {
            case .ingredients(let rhsValue):
                return lhsValue == rhsValue
            default:
                return false
            }
        case .nutrition(let lhsValue):
            switch rhs {
            case .nutrition(let rhsValue):
                return lhsValue == rhsValue
            default:
                return false
            }
        case .packaging(let lhsValue):
            switch rhs {
            case .packaging(let rhsValue):
                return lhsValue == rhsValue
            default:
                return false
            }
        case .general(let lhsValue):
            switch rhs {
            case .general(let rhsValue):
                return lhsValue == rhsValue
            default:
                return false
            }
        }
    }

    // Roughly equatable, by looking only at the enums and not the associated values
    static func ~=(lhs: ImageTypeCategory, rhs: ImageTypeCategory) -> Bool {
        switch lhs {
        case .front(_):
            switch rhs {
            case .front(_):
                return true
            default:
                return false
            }
        case .ingredients(_):
            switch rhs {
            case .ingredients(_):
                return true
            default:
                return false
            }
        case .nutrition(_):
            switch rhs {
            case .nutrition(_):
                return true
            default:
                return false
            }
        case .packaging(_):
            switch rhs {
            case .packaging(_):
                return true
            default:
                return false
            }
        case .general(_):
            switch rhs {
            case .general(_):
                return true
            default:
                return false
            }
        }
    }

    case general(String)
    case front(String)
    case ingredients(String)
    case nutrition(String)
    case packaging(String)
    
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
        case .general(_):
            return "general"
        }
    }

    // These decriptions are used in the deselect/update API's to OFF
    public var associatedString: String {
        switch self {
        case .front(let string):
            return string
        case .ingredients(let string):
            return string
        case .nutrition(let string):
            return string
        case .packaging(let string):
            return string
        case .general(let string):
            return string
        }
    }

    static var list: [ImageTypeCategory] {
        return [.front(""),
                .ingredients(""),
                .nutrition(""),
                .packaging("")]
    }
    
    static func type(for string: String) -> ImageTypeCategory {
        switch string {
        case ImageTypeCategory.front("").description:
            return .front("")
        case ImageTypeCategory.ingredients("").description:
            return .ingredients("")
        case ImageTypeCategory.nutrition("").description:
            return .nutrition("")
        case ImageTypeCategory.packaging("").description:
            return .packaging("")
        default:
            return .general("")
        }
    }
    
    static func type(typeString: String, associated: String) -> ImageTypeCategory {
        switch typeString {
        case ImageTypeCategory.front("").description:
            return .front(associated)
        case ImageTypeCategory.ingredients("").description:
            return .ingredients(associated)
        case ImageTypeCategory.nutrition("").description:
            return .nutrition(associated)
        case ImageTypeCategory.packaging("").description:
            return .packaging(associated)
        default:
            return .general(associated)
        }
    }

    public var rawValue: Int {
        switch self {
        case .front:
            return 1
        case .ingredients:
            return 2
        case .nutrition:
            return 3
        case .packaging:
            return 4
        case .general:
            return 0
        }
    }
}
