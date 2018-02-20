//
//  Completion.swift
//  FoodViewer
//
//  Created by arnaud on 11/09/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

// The strings are used in the URL's of the search query, so we look for the right thing
public struct Completion: Hashable {
    
    
    var category: CompletionCategory = .productName
    
    var description: String {
        return OFFplists.manager.translateStates(OFF.JSONkey(for: self), language:Locale.preferredLanguages[0])
    }
    
    public var hashValue: Int {
        return category.rawValue
    }
    
    public static func ==(lhs: Completion, rhs: Completion) -> Bool {
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
        case .expiration_date_completed:
            category = .expirationDate
            value = true
        case .expiration_date_to_be_completed:
            category = .expirationDate
            value = false
        case .ingredients_completed:
            category = .ingredients
            value = true
        case .ingredients_to_be_completed:
            category = .ingredients
            value = false
        case .nutrition_facts_completed:
            category = .nutritionFacts
            value = true
        case .nutrition_facts_to_be_completed:
            category = .nutritionFacts
            value = false
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
        case .to_be_checked:
            category = .checked
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
             .categories,
             .expirationDate,
             .nutritionFacts,
             .complete,
             .characteristics,
             .packagingCode,
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
             .categories,
             .expirationDate,
             .nutritionFacts,
             .complete,
             .characteristics,
             .packagingCode,
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
