//
//  SIUnit.swift
//  FoodViewer
//
//  Created by arnaud on 14/03/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

public class SIUnit {
    
    public var unit: String {
        get {
            return ""
        }
    }
    
    public var quantity: Double? = nil
    
    public init() {
        self.quantity = nil
    }
    
    public func description() -> String {
        if let validValue = quantity {
            return "\(validValue) " + self.unit
        } else {
            return "nil " + self.unit
        }
    }
    
    public func set (_ quantity: Double?, prefix: String) {
        guard quantity != nil else {
            self.quantity = nil
            return
        }
        
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
    
    public var inGiga: (Double?, String) {
        get {
            let value = self.quantity != nil ? self.quantity! / MetricPrefix.Giga.Factor : nil
            return (value, MetricPrefix.Giga.Symbol + self.unit)
        }
    }
    
    public var inMega: (Double?, String) {
        get {
            let value = self.quantity != nil ? self.quantity! / MetricPrefix.Mega.Factor : nil
            return (value, MetricPrefix.Mega.Symbol + self.unit)
        }
    }
    
    public var inKilo: (Double?, String) {
        get {
            let value = self.quantity != nil ? self.quantity! / MetricPrefix.Kilo.Factor : nil
            return (value, MetricPrefix.Kilo.Symbol + self.unit)
        }
    }

    public var inMilli: (Double?, String) {
        get {
            let value = self.quantity != nil ? self.quantity! / MetricPrefix.Milli.Factor : nil
            return (value, MetricPrefix.Milli.Symbol + self.unit)
        }
    }

    public var inMicro: (Double?, String) {
        get {
            let value = self.quantity != nil ? self.quantity! / MetricPrefix.Micro.Factor : nil
            return (value, MetricPrefix.Micro.Symbol + self.unit)
        }
    }

    public var inNano: (Double?, String) {
        get {
            let value = self.quantity != nil ? self.quantity! / MetricPrefix.Nano.Factor : nil
            return (value, MetricPrefix.Nano.Symbol + self.unit)
        }
    }

}
