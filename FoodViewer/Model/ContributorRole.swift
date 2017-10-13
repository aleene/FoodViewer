//
//  ContributorRole.swift
//  FoodViewer
//
//  Created by arnaud on 12/10/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

enum ContributorRole {
    
    case checker
    case informer
    case editor
    case photographer
    case creator
    case corrector
    
    init() {
        self = .creator
    }

    public var description: String {
        switch self {
        case .checker:
            return TranslatableStrings.Checker
        case .informer:
            return TranslatableStrings.Informer
        case .editor:
            return TranslatableStrings.Editor
        case .photographer:
            return TranslatableStrings.Photographer
        case .creator:
            return TranslatableStrings.Creator
        case .corrector:
            return TranslatableStrings.Corrector
        }
    }
}
