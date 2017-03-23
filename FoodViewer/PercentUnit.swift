//
//  PercentUnit.swift
//  FoodViewer
//
//  Created by arnaud on 17/03/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

public class PercentUnit: SIUnit {
    
    override public init() {
        super.init()
    }
    
    override public var unit: String {
        get {
            return "%"
        }
    }
    
    public var quantityInPercent: Double? {
        get {
            return quantity != nil ? quantity! / 100.0 : nil
        }
        set {
            quantity = newValue != nil ? newValue! * 100.0 : nil
        }
    }
    
    public func setInPercent(_ quantity: Double?) {
        guard quantity != nil else {
            self.quantity = nil
            return
        }
        
        // convert to Percent
        self.quantityInPercent = quantity
    }

}
