//
//  TagsType.swift
//  FoodViewer
//
//  Created by arnaud on 31/07/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

enum TagsType {
    case original
    case interpreted
    case translated
    case hierarchy
    case edited
    
    public mutating func cycle() {
        switch self {
        case .original:
            self = .interpreted
        case .interpreted:
            self = .translated
        case .translated:
            self = .hierarchy
        case .hierarchy:
            self = .edited
        case .edited:
            self = .original
        }
    }
    
    func description() -> String {
        switch self {
        case .original:
            return NSLocalizedString("Original", comment: "Description of the original tags in the json")
        case .interpreted:
            return NSLocalizedString("Interpreted", comment: "Description of the by OFF interpreted tags in the json")
        case .translated:
            return NSLocalizedString("Translated", comment: "Description of the interpreted tags in the json as translated by the taxonomy")
        case .hierarchy:
            return NSLocalizedString("Hierarchy", comment: "Description of the hierarchy tags in the json")
        case .edited:
            return NSLocalizedString("Edited", comment: "Description of the edited tags as will be uploaded")
        }
    }

}

