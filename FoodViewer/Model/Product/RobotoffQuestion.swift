//
//  RobotoffQuestion.swift
//  FoodViewer
//
//  Created by arnaud on 19/10/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import Foundation

enum RobotoffQuestionType: String {
    case brand = "brand"
    case category = "category"
    case expirationDate = "expiration_date"
    case ingredientSpellcheck = "ingredient_spellcheck"
    case label = "label"
    case nutrient = "nutrient"
    case packagerCode = "packager_code"
    case quantity = "product_weight"
    case store = "store"
    case unknown
}

enum RobotoffQuestionResponse: Int {
    case accept = 1
    case unknown = 0
    case refuse = -1
}

struct RobotoffQuestion {
    var barcode: String?
    var question: String?
    var value: String?
    var field: RobotoffQuestionType = .unknown
    var id: String? // needed to report back?
    var url: String?
    var response: RobotoffQuestionResponse?
    
    init(jsonQuestion: OFFRobotoffQuestion) {
        barcode = jsonQuestion.barcode
        question = jsonQuestion.question
        id = jsonQuestion.insight_id
        value = jsonQuestion.value
        url = jsonQuestion.source_image_url
        if let type = jsonQuestion.insight_type {
            switch type {
            case RobotoffQuestionType.brand.rawValue:
                field = .brand
            case RobotoffQuestionType.category.rawValue:
                field = .category
            case RobotoffQuestionType.expirationDate.rawValue:
                field = .expirationDate
            case RobotoffQuestionType.ingredientSpellcheck.rawValue:
                field = .ingredientSpellcheck
            case RobotoffQuestionType.label.rawValue:
                field = .label
            case RobotoffQuestionType.nutrient.rawValue:
                field = .nutrient
            case RobotoffQuestionType.packagerCode.rawValue:
                field = .packagerCode
            case RobotoffQuestionType.quantity.rawValue:
                field = .quantity
            case RobotoffQuestionType.store.rawValue:
                field = .store
            default:
                field =  .unknown
            }
        } else {
            field = .unknown
        }
    }
    
    var imageID: String? {
        guard let validURLString = url else { return nil }
        // https://static.openfoodfacts.org/images/products/303/349/000/4743/37.400.jpg
        guard let imagePart = validURLString.split(separator: "/").last else { return nil }
        let validID = imagePart.split(separator: ".")
        guard validID.last == "jpg" else { return nil }
        return String(validID.first!)
    }
}

// MARK: - Equatable

extension RobotoffQuestion: Equatable {
    static func ==(lhs: RobotoffQuestion, rhs: RobotoffQuestion) -> Bool {
        guard let validLHSid = lhs.id else { return false }
        guard let validRHSid = rhs.id else { return false }
        return validLHSid == validRHSid
    }
}
