//
//  SearchComponent.swift
//  FoodViewer
//
//  Created by arnaud on 16/10/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

// All the product fields that can be used for searching a product
public enum SearchComponent {
    case additive
    case allergen
    case barcode
    case brand
    case category
    case checker
    case creator
    case contributor // not searchable at the moment
    case corrector
    case country
    case editor
    case entryDates
    case informer
    case label
    case language
    case lastEditDate
    case manufacturingPlaces
    case nutrient
    case nutritionGrade
    case origin
    case packaging
    case purchasePlace
    case photographer
    case producerCode
    case searchText
    case state
    case store
    case trace

    public var description: String {
        switch self {
        case .additive:
            return TranslatableStrings.Additives
        case .allergen:
            return TranslatableStrings.Allergens
        case .barcode:
            return TranslatableStrings.Barcode
        case .brand:
            return TranslatableStrings.Brands
        case .category:
            return TranslatableStrings.Categories
        case .checker:
            return TranslatableStrings.Checker
        case .contributor:
            return TranslatableStrings.Contributor
        case .corrector:
            return TranslatableStrings.Corrector
        case .country:
            return TranslatableStrings.Countries
        case .creator:
            return TranslatableStrings.Creator
        case .editor:
            return TranslatableStrings.Editor
        case .entryDates:
            return TranslatableStrings.EntryDate
        case .informer:
            return TranslatableStrings.Informer
        case .label:
            return TranslatableStrings.Labels
        case .language:
            return TranslatableStrings.Languages
        case .lastEditDate:
            return TranslatableStrings.LastEditDate
        case .manufacturingPlaces:
            return TranslatableStrings.Manufacturer
        case .nutrient:
            return TranslatableStrings.Nutrients
        case .nutritionGrade:
            return TranslatableStrings.NutritionalScore
        case .origin:
            return TranslatableStrings.IngredientOrigins
        case .packaging:
            return TranslatableStrings.Packaging
        case .photographer:
            return TranslatableStrings.Photographer
        case .producerCode:
            return TranslatableStrings.PackagerCodes
        case .purchasePlace:
            return TranslatableStrings.PurchaseAddress
        case .searchText:
            return TranslatableStrings.SearchText
        case .state:
            return TranslatableStrings.CompletionStates
        case .store:
            return TranslatableStrings.Stores
        case .trace:
            return TranslatableStrings.Traces
        }
    }
}
