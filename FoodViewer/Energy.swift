//
//  Energy2.swift
//  FoodViewer
//
//  Created by arnaud on 16/03/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

public class Energy: SIUnit {
    
    override public init() {
        super.init()
    }
    
    override public var unit: String {
        get {
            return "J"
        }
    }
    
    public var quantityInCalories: Double? {
        get {
            return quantity != nil ? quantity! / 4.184 : nil
        }
        set {
            quantity = newValue != nil ? newValue! * 4.184 : nil
        }
    }
    
    public let calUnit = "cal"
    public let largeCalUnit = "Cal"
    public func setInCalories (_ quantity: Double?, prefix: String) {
        guard quantity != nil else {
            self.quantity = nil
            return
        }
        // convert to Joule
        self.quantityInCalories = quantity
        
        if prefix.hasPrefix(MetricPrefix.Giga.Symbol) {
            self.quantity = quantity! * MetricPrefix.Giga.Factor
        } else if prefix.hasPrefix(MetricPrefix.Mega.Symbol) {
            self.quantity = quantity! * MetricPrefix.Mega.Factor
        } else if prefix.hasPrefix(MetricPrefix.Kilo.Symbol) {
            self.quantity = quantity! * MetricPrefix.Kilo.Factor
        } else if prefix.hasPrefix( MetricPrefix.Milli.Symbol) {
            self.quantity = quantity! * MetricPrefix.Milli.Factor
        } else if prefix.hasPrefix(MetricPrefix.Micro.Symbol) {
            self.quantity = quantity! * MetricPrefix.Micro.Factor
        } else if prefix.hasPrefix(MetricPrefix.Nano.Symbol) {
            self.quantity = quantity! * MetricPrefix.Nano.Factor
        } else {
            self.quantity = quantity
        }
    }

    public var inGigaCalories: (Double?, String) {
        get {
            let value = self.quantityInCalories != nil ? self.quantityInCalories! / MetricPrefix.Giga.Factor : nil
            return (value, MetricPrefix.Giga.Symbol + self.calUnit)
        }
    }
    
    public var inMegaCalories: (Double?, String) {
        get {
            let value = self.quantityInCalories != nil ? self.quantityInCalories! / MetricPrefix.Mega.Factor : nil
            return (value, MetricPrefix.Mega.Symbol + self.calUnit)
        }
    }
    
    public var inKiloCalories: (Double?, String) {
        get {
            let value = self.quantityInCalories != nil ? self.quantityInCalories! / MetricPrefix.Kilo.Factor : nil
            return (value, MetricPrefix.Kilo.Symbol + self.calUnit)
        }
    }
    
    public var inLargeCalories: (Double?, String) {
        get {
            let value = self.quantityInCalories != nil ? self.quantityInCalories! / MetricPrefix.Kilo.Factor : nil
            return (value, self.largeCalUnit)
        }
    }

    public var inMilliCalories: (Double?, String) {
        get {
            let value = self.quantityInCalories != nil ? self.quantityInCalories! / MetricPrefix.Milli.Factor : nil
            return (value, MetricPrefix.Milli.Symbol + self.calUnit)
        }
    }
    
    public var inMicroCalories: (Double?, String) {
        get {
            let value = self.quantityInCalories != nil ? self.quantityInCalories! / MetricPrefix.Micro.Factor : nil
            return (value, MetricPrefix.Micro.Symbol + self.unit)
        }
    }
    
    public var inNanoCalories: (Double?, String) {
        get {
            let value = self.quantityInCalories != nil ? self.quantityInCalories! / MetricPrefix.Nano.Factor : nil
            return (value, MetricPrefix.Nano.Symbol + self.calUnit)
        }
    }

}
