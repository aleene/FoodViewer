//
//  RobotoffQuestion.swift
//  FoodViewer
//
//  Created by arnaud on 19/10/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import Foundation

enum RobotoffQuestionField: String {
    case label = "label"
    case category = "category"
    case unknown
}

struct RobotoffQuestion {
    var barcode: String?
    var question: String?
    var value: String?
    var field: RobotoffQuestionField = .unknown
    var id: String? // needed to report back?
    
    init(jsonQuestion: OFFRobotoffQuestion) {
        barcode = jsonQuestion.barcode
        question = jsonQuestion.question
        id = jsonQuestion.insight_id
        value = jsonQuestion.value
        if let type = jsonQuestion.insight_type {
            switch type {
            case RobotoffQuestionField.label.rawValue:
                field = .label
            case RobotoffQuestionField.category.rawValue:
                field = .category
            default:
                field =  .unknown
            }
        } else {
            field = .unknown
        }
    }
}
