//
//  RobotoffQuestion.swift
//  FoodViewer
//
//  Created by arnaud on 19/10/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import Foundation

enum RobotoffQuestionType: String {
    case label = "label"
    case category = "category"
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
    var response: RobotoffQuestionResponse?
    
    init(jsonQuestion: OFFRobotoffQuestion) {
        barcode = jsonQuestion.barcode
        question = jsonQuestion.question
        id = jsonQuestion.insight_id
        value = jsonQuestion.value
        if let type = jsonQuestion.insight_type {
            switch type {
            case RobotoffQuestionType.label.rawValue:
                field = .label
            case RobotoffQuestionType.category.rawValue:
                field = .category
            default:
                field =  .unknown
            }
        } else {
            field = .unknown
        }
    }
}
