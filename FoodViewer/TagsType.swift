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
    case prefixed
    
    public mutating func cycle() {
        switch self {
        case .original:
            self = .interpreted
        case .interpreted:
            self = .translated
        case .translated:
            self = .hierarchy
        case .hierarchy:
            self = .prefixed
        case .prefixed:
            self = .edited
        case .edited:
            self = .original
        }
    }
    
    func description() -> String {
        switch self {
        case .original:
            return TranslatableStrings.Original
        case .interpreted:
            return TranslatableStrings.Interpreted
        case .translated:
            return TranslatableStrings.Translated
        case .hierarchy:
            return TranslatableStrings.Hierarchy
        case .prefixed:
            return TranslatableStrings.PrefixCorrected
        case .edited:
            return TranslatableStrings.Edited
        }
    }

}

