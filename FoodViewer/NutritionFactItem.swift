//
//  NutritionFactItem.swift
//  FoodViewer
//
//  Created by arnaud on 10/04/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

public struct NutritionFactItem {
    public var itemName: String? = nil
    public var standardValue: String? = nil
    public var standardValueUnit: NutritionFactUnit? = nil
    public var servingValue: String? = nil
    public var servingValueUnit: NutritionFactUnit? = nil
    public var dailyFractionPerServing: Double? = nil
    public var key: String? = nil

    public init() {
        itemName = nil
        standardValue = nil
        standardValueUnit = nil
        servingValue = nil
        servingValueUnit = nil
        key = nil
    }

    public init(name: String?, standard: String?, serving: String?, unit: String?, key: String?) {
        itemName = name
        standardValue = standard
        servingValue = serving
        if let validUnit = unit {
            standardValueUnit = NutritionFactUnit(validUnit)
            servingValueUnit = NutritionFactUnit(validUnit)
        }
        self.key = key
    }

    func valid() -> Bool {
        return standardValue != nil && !standardValue!.isEmpty
    }
    
    struct Constants {
        static let CaloriesPerJoule = Float(4.2)
    }

    func valueInCalories(_ stringValue: String?) -> String {
        
        if let value = stringValue {
            guard !value.isEmpty else { return "" }
            
            let newValue = value.replacingOccurrences(of: "\u{a0}", with: "")

            if let floatValue = newValue.floatValue {
                let division = floatValue / Constants.CaloriesPerJoule
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                let str = numberFormatter.string(from: NSNumber(floatLiteral: Double(division)))
                guard (str != nil) else { return "" }
                return str!
            } else {
                return value
            }
        }
        return ""
    }
    func localeStandardValue() -> String {
        return localeValue(standardValue)
    }
    
    func localeServingValue() -> String {
        return localeValue(servingValue)
    }

    fileprivate func localeValue(_ stringValue: String?) -> String {

        if let value = stringValue {
            // an empty string does not have to be analysed
            guard !value.isEmpty else { return "" }
            /*
            for c in value.unicodeScalars {
                print(String(c.value, radix: 16))
            }
             */
            // remove any unicode a0 (non-breaking space)
            let newValue = value.replacingOccurrences(of: "\u{a0}", with: "")

            // accept numbers with a , or . separator
            if let floatValue = newValue.floatValue {
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                let str = numberFormatter.string(from: NSNumber(value: floatValue))
                guard (str != nil) else { return "" }
                return str!
            } else {
                return value
            }
        }
        return ""

    }

    func localeDailyValue() -> String {
        
        if let validValue = dailyFractionPerServing {
            
            // convert standard value to a number in the users locale
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .percent
            if let returnString = numberFormatter.string(from: NSNumber.init(value: validValue as Double)) {
                return returnString
            }
        }
        return ""
    }

}

extension String {
    var floatValue: Float? {
        let nf = NumberFormatter()
        nf.decimalSeparator = "."
        if let result = nf.number(from: self) {
            return result.floatValue
        } else {
            nf.decimalSeparator = ","
            if let result = nf.number(from: self) {
                return result.floatValue
            }
        }
        return nil
    }
}



