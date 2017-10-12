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
            return TranslatableStrings.Model.ContributorRole.Checker
        case .informer:
            return TranslatableStrings.Model.ContributorRole.Informer
        case .editor:
            return TranslatableStrings.Model.ContributorRole.Editor
        case .photographer:
            return TranslatableStrings.Model.ContributorRole.Photographer
        case .creator:
            return TranslatableStrings.Model.ContributorRole.Creator
        case .corrector:
            return TranslatableStrings.Model.ContributorRole.Corrector
        }
    }
}
