//
//  OFFRobotoffQuestionJson.swift
//  FoodViewer
//
//  Created by arnaud on 18/10/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import Foundation

class OFFRobotoffQuestionJson : Codable {
    
    var questions: [OFFRobotoffQuestion]?
    var status: String? // "found"
    
}
