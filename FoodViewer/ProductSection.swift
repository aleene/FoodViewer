//
//  ProductSection.swift
//  FoodViewer
//
//  Created by arnaud on 25/08/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

public enum ProductPage {
    
    case environment
    case identification
    case gallery
    case ingredients
    case nutritionFacts
    case nutritionScore
    case categories
    case completion
    case dietCompliancy
    case supplyChain
    case json
    case notSet
    case notAvailable

    var description: String {
        switch self {
        case .environment:
            return  TranslatableStrings.Environment
        case .identification:
            return  TranslatableStrings.Identification
        case .ingredients:
            return TranslatableStrings.Ingredients
        case .gallery:
            return TranslatableStrings.Gallery
        case .nutritionFacts:
            return TranslatableStrings.NutritionFacts
        case .nutritionScore:
            return TranslatableStrings.NutritionalScore
        case .categories:
            return TranslatableStrings.Categories
        case .completion:
            return TranslatableStrings.CommunityEffort
        case .supplyChain:
            return TranslatableStrings.SupplyChain
        case .dietCompliancy:
            return TranslatableStrings.DietCompliancy
        case .json:
            return TranslatableStrings.Json
        case .notSet:
            return TranslatableStrings.ProductNotSet
        case .notAvailable:
            return TranslatableStrings.ProductNotAvailable
        }
    }
    
}
