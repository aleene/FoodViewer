//
//  OFFProductForestFootPrintDataIngredientsTypeDetailed.swift
//  FoodViewer
//
//  Created by Arnaud Leene on 05/09/2022.
//  Copyright © 2022 Hovering Above. All rights reserved.
//

import Foundation

class OFFProductForestFootPrintDataIngredientsTypeDetailed: OFFProductForestFootPrintDataIngredientsType {
    
    struct DetailedKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        var intValue: Int? { return nil }
        init?(intValue: Int) { return nil }
        
        static let deforestation_risk = DetailedKeys(stringValue: "deforestation_risk")!
        static let soy_feed_factor = DetailedKeys(stringValue: "soy_feed_factor")!
        static let soy_yield = DetailedKeys(stringValue: "soy_yield")!
    }
    
    public var deforestation_risk: String? = nil
    public var soy_feed_factor: String? = nil
    public var soy_yield: String? = nil

    required init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: DetailedKeys.self)
        
        self.deforestation_risk = container.forceString(key: .deforestation_risk)
        self.soy_feed_factor = container.forceString(key: .soy_feed_factor)
        self.soy_yield = container.forceString(key: .soy_yield)

        try super.init(from: decoder)
    }
    
}
