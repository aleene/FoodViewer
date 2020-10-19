//
//  OFFRobotoffQuestion.swift
//  FoodViewer
//
//  Created by arnaud on 19/10/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import Foundation

/*
    API url
        Endpoint.robotoff + "/api/v1/questions/\(barcode)?lang=\(Locale.interfaceLanguageCode)&count=6"

    An example respons:
 {
    "questions":
    [
        {
            "barcode":"3033490004743",
            "type":"add-binary",
            "value":"Green Dot",
            "question":"Does the product have this label?",
            "insight_id":"83ad625d-f615-4367-95cb-06e0a420080a",
            "insight_type":"label",
            "source_image_url":"https://static.openfoodfacts.org/images/products/303/349/000/4743/37.400.jpg"
        }
    ],
    "status":"found"
 }
 */
class OFFRobotoffQuestion: Codable {
    
    var barcode: String?            // "3336590106264"
    /// Only the add-binary should be used for questions
    var type: String?               // "add-binary"
    var value: String?              // "Green Dot"
    var question: String?           // "Does the product have this label?"
    var insight_id: String?         // "83ad625d-f615-4367-95cb-06e0a420080a"
    var insight_type: String?       // "label"
    var source_image_url: String?   // "https://static.openfoodfacts.org/images/products/303/349/000/4743/37.400.jpg"
}
