//
//  ProductAttributeGroup.swift
//  FoodViewer
//
//  Created by arnaud on 09/09/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import Foundation
/* example:
 "id":"processing",
 "attributes":
     [
         {
         "title":"NOVA 3",
         "description":"",
         "description_short":"Processed foods",
         "status":"known",
         "match":50,
         "name":"NOVA group",
         "id":"nova"
         }
     ],
 "name":"Food processing"
*/

enum ProductAttributeGroupID {
    case nutritional_quality
    case processing
    case labels
    case unknown
}
struct ProductAttributeGroup {
    var id: ProductAttributeGroupID
    var name: String
    var attributes: [ProductAttribute]
    
    init(data: OFFProductAttributeGroup) {
        switch data.id {
        case "nutritional_quality":
            self.id = .nutritional_quality
        case "processing":
            self.id = .processing
        case "labels":
            self.id = .labels
        default:
            self.id = .unknown
        }
        self.name = data.name
        var attributes: [ProductAttribute] = []
        for offAttribute in data.attributes {
            attributes.append(ProductAttribute(offAttribute))
        }
        self.attributes = attributes
    }
}
