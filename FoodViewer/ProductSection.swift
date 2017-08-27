//
//  ProductSection.swift
//  FoodViewer
//
//  Created by arnaud on 25/08/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

public enum ProductSection {
    
    case identification
    case gallery
    case ingredients
    case nutritionFacts
    case nutritionScore
    case categories
    case completion
    case supplyChain
    
    private struct Title {
        static let Identification = NSLocalizedString("Identification", comment: "Viewcontroller title for page with product identification info.")
        static let Ingredients = NSLocalizedString("Ingredients", comment: "Viewcontroller title for page with ingredients for product.")
        static let Facts = NSLocalizedString("Nutritional facts", comment: "Viewcontroller title for page with nutritional facts for product.")
        static let SupplyChain = NSLocalizedString("Supply Chain", comment: "Viewcontroller title for page with supply chain for product.")
        static let Categories = NSLocalizedString("Categories", comment: "Viewcontroller title for page with categories for product.")
        static let Effort = NSLocalizedString("Community Effort", comment: "Viewcontroller title for page with community effort for product.")
        static let Score = NSLocalizedString("Nutritional Score", comment: "Viewcontroller title for page with explanation of the nutritional score of the product.")
        static let Gallery = NSLocalizedString("Gallery", comment: "Viewcontroller title for page with images of the product")
    }

    func description() -> String {
        switch self {
        case .identification:
            return  Title.Identification
        case .ingredients:
            return Title.Ingredients
        case .gallery:
            return Title.Gallery
        case .nutritionFacts:
            return Title.Facts
        case .nutritionScore:
            return Title.Score
        case .categories:
            return Title.Categories
        case .completion:
            return Title.Effort
        case .supplyChain:
            return  Title.SupplyChain
        }
    }
    

}
