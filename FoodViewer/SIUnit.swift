//
//  SIUnit.swift
//  FoodViewer
//
//  Created by arnaud on 14/03/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

public class SIUnit {
    
    public var quantity: (Double?, String) = (nil, "")
    
    public init() {
        self.quantity = (nil, "")
    }
    
    public init(_ value: Double, unit: String) {
        self.quantity = (value, unit)
    }
    
    public func description() -> String {
        if let validValue = quantity.0 {
            return "\(validValue) " + quantity.1
        } else {
            return quantity.1
        }
    }
}
