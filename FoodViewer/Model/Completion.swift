//
//  Completion.swift
//  FoodViewer
//
//  Created by arnaud on 11/09/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

// The strings are used in the URL's of the search query, so we look for the right thing
public struct ProductCompletion: Hashable {
    
    
    var category: CompletionCategory = .productName
    
    var description: String {
        return OFFplists.manager.translateState(OFF.JSONkey(for: self), language:Locale.preferredLanguages[0]) ?? OFF.JSONkey(for: self)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(category.rawValue)
    }
    
    public static func ==(lhs: ProductCompletion, rhs: ProductCompletion) -> Bool {
        return lhs.category.rawValue == rhs.category.rawValue
    }
    
    public var value: Bool = false

    init(_ category: CompletionCategory, isCompleted value:Bool) {
        self.category = category
        self.value = value
    }
    
    // Converts the OFFProductStates back to a Completion object
    init(with state: OFFProductStates) {
        switch state {
        case .brands_completed:
            category = .brands
            value = true
        case .brands_to_be_completed:
            category = .brands
            value = false
        case .categories_completed:
            category = .categories
            value = true
        case .categories_to_be_completed:
            category = .categories
            value = false
        case .checked:
            category = .checked
            value = true
        case .to_be_checked:
            category = .checked
            value = false
        case .expiration_date_completed:
            category = .expirationDate
            value = true
        case .expiration_date_to_be_completed:
            category = .expirationDate
            value = false
        case .front_photo_selected:
            category = .frontPhoto
            value = true
        case .front_photo_to_be_selected:
            category = .frontPhoto
            value = false
        case .ingredients_completed:
            category = .ingredients
            value = true
        case .ingredients_to_be_completed:
            category = .ingredients
            value = false
        case .ingredients_photo_selected:
            category = .ingredientsPhoto
            value = true
        case .ingredients_photo_to_be_selected:
            category = .ingredientsPhoto
            value = false
        case .nutrition_facts_completed:
            category = .nutritionFacts
            value = true
        case .nutrition_facts_to_be_completed:
            category = .nutritionFacts
            value = false
        case .nutrition_photo_selected:
            category = .nutritionPhoto
            value = true
        case .nutrition_photo_to_be_selected:
            category = .nutritionPhoto
            value = false
        case .origins_to_be_completed:
            category = .origins
            value = false
        case .origins_completed:
            category = .origins
            value = true
        case .packaging_completed:
            category = .packaging
            value = true
        case .packaging_to_be_completed:
            category = .packaging
            value = false
        case .photos_uploaded:
            category = .photosUploaded
            value = true
        case .photos_to_be_uploaded:
            category = .photosUploaded
            value = false
        case .photos_validated:
            category = .photosValidated
            value = true
        case .photos_to_be_validated:
            category = .photosValidated
            value = false
        case .product_name_completed:
            category = .productName
            value = true
        case .product_name_to_be_completed:
            category = .productName
            value = false
        case .quantity_completed:
            category = .quantity
            value = true
        case .quantity_to_be_completed:
            category = .quantity
            value = false
        case .characteristics_completed:
            category = .characteristics
            value = true
        case .characteristics_to_be_completed:
            category = .characteristics
            value = false
        case .complete:
            category = .complete
            value = true
        case .packaging_code_completed:
            category = .packagingCode
            value = true
        case .packaging_code_to_be_completed:
            category = .packagingCode
            value = false
        case .packaging_photo_not_selected, .packaging_photo_to_be_selected:
            category = .packagingPhoto
            value = false
        case .packaging_photo_selected:
            category = .packagingPhoto
            value = true
        case .to_be_completed:
            category = .complete
            value = false
        case .empty:
            category = .complete
            value = false
        }
    }

    var ready: String {
        switch self.category {
        case .productName,
             .brands,
             .quantity,
             .packaging,
             .ingredients,
             .ingredientsPhoto,
             .categories,
             .expirationDate,
             .frontPhoto,
             .nutritionFacts,
             .nutritionPhoto,
             .complete,
             .characteristics,
             .origins,
             .packagingCode,
             .packagingPhoto,
             .checked:
            return TranslatableStrings.Set
        case .photosUploaded,
             .photosValidated:
            return TranslatableStrings.Done
        }
    }
    
    var notReady: String {
        switch self.category {
        case .productName,
             .brands,
             .quantity,
             .packaging,
             .ingredients,
             .ingredientsPhoto,
             .categories,
             .expirationDate,
             .frontPhoto,
             .nutritionFacts,
             .nutritionPhoto,
             .complete,
             .characteristics,
             .origins,
             .packagingCode,
             .packagingPhoto,
             .checked:
            return TranslatableStrings.NotSet
        case .photosUploaded,
             .photosValidated:
            return TranslatableStrings.NotDone
        }
    }

    var cleanedState: String? {
        var elements = self.description.split(separator: " ").map(String.init)
        if elements.count > 0 {
            elements.remove(at: elements.count - 1)
            return elements.joined(separator: " ")
        }
        return nil
    }
    
}
