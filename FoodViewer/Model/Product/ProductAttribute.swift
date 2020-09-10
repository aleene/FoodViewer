//
//  ProductAttribute.swift
//  FoodViewer
//
//  Created by arnaud on 09/09/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import Foundation

/* example:
 "title":"Nutri-Score D",
 "description_short":"Poor nutritional quality",
 "description":"",
 "match":30,
 "name":"Nutri-Score",
 "status":"known",
 "id":"nutriscore"
 */

enum ProductAttributeID {
    case nutriscore
    case nova
    case labels_organic
    case labels_fair_trade
    case unknown
}

struct ProductAttribute {
    var title: String?
    var description_short: String
    var description: String
    var match: Double
    var name: String
    var status: String
    var id: ProductAttributeID
    
    init(_ data: OFFProductAttribute) {
        self.title = data.title
        self.description = data.description
        self.description_short = data.description_short
        self.match = data.match
        self.name = data.name
        self.status = data.status
        switch data.id {
        case "nutriscore":
            self.id = .nutriscore
        case "nova":
            self.id = .nova
        case "labels_fair_trade":
            self.id = .labels_fair_trade
        case "labels_organic":
            self.id = .labels_organic
        default:
            self.id = .unknown
        }
    }
}
