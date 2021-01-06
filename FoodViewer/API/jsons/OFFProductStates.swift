//
//  OFFProductStates.swift
//  FoodViewer
//
//  Created by arnaud on 09/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation

public enum OFFProductStates: String, Codable {
    case brands_completed = "en:brands-completed"
    case brands_to_be_completed = "en:brands-to-be-completed"
    case categories_completed = "en:categories-completed"
    case categories_to_be_completed = "en:categories-to-be-completed"
    case characteristics_completed = "en:characteristics-completed"
    case characteristics_to_be_completed = "en:characteristics-to-be-completed"
    case checked = "en:checked"
    case complete = "en:complete"
    case empty = "en:empty"
    case expiration_date_completed = "en:expiration-date-completed"
    case expiration_date_to_be_completed = "en:expiration-date-to-be-completed"
    case front_photo_selected = "en:front-photo-selected"
    case front_photo_to_be_selected = "en:front-photo-to-be-selected"
    case ingredients_completed = "en:ingredients-completed"
    case ingredients_to_be_completed = "en:ingredients-to-be-completed"
    case ingredients_photo_selected = "en:ingredients-photo-selected"
    case ingredients_photo_to_be_selected = "en:ingredients-photo-to-be-selected"
    case nutrition_facts_completed = "en:nutrition-facts-completed"
    case nutrition_facts_to_be_completed = "en:nutrition-facts-to-be-completed"
    case nutrition_photo_selected = "en:nutrition-photo-selected"
    case nutrition_photo_to_be_selected = "en:nutrition-photo-to-be-selected"
    case origins_completed = "en:origins-completed"
    case origins_to_be_completed = "en:origins-to-be-completed"
    case packaging_completed = "en:packaging-completed"
    case packaging_to_be_completed = "en:packaging-to-be-completed"
    case packaging_code_completed = "en:packaging-code-completed"
    case packaging_code_to_be_completed = "en:packaging-code-to-be-completed"
    case packaging_photo_not_selected = "en:packaging-photo-not-selected"
    case packaging_photo_to_be_selected = "en:packaging-photo-to-be-selected"
    case packaging_photo_selected = "en:packaging-photo-selected"
    case photos_uploaded = "en:photos-uploaded"
    case photos_to_be_uploaded = "en:photos-to-be-uploaded"
    case photos_validated = "en:photos-validated"
    case photos_to_be_validated = "en:photos-to-be-validated"
    case product_name_completed = "en:product-name-completed"
    case product_name_to_be_completed = "en:product-name-to-be-completed"
    case quantity_completed = "en:quantity-completed"
    case quantity_to_be_completed = "en:quantity-to-be-completed"
    case to_be_checked = "en:to-be-checked"
    case to_be_completed = "en:to-be-completed"
}

