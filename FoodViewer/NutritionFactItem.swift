//
//  NutritionFactItem.swift
//  FoodViewer
//
//  Created by arnaud on 10/04/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

struct NutritionFactItem {
    var itemName: String? = nil
    var standardValue: String? = nil
    var standardValueUnit: NutritionFactUnit? = nil
    var servingValue: String? = nil
    var servingValueUnit: NutritionFactUnit? = nil
    var dailyFractionPerServing: Double? = nil
    var key: String? = nil

    init() {
        itemName = nil
        standardValue = nil
        standardValueUnit = nil
        servingValue = nil
        servingValueUnit = nil
        key = nil
    }

    init(name: String?, standard: String?, serving: String?, unit: String?, key: String?) {
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
        static let CaloriesPerJoule = 4.2
    }

    func valueInCalories(_ stringValue: String?) -> String {
        
        if let value = stringValue {
            guard !value.isEmpty else { return "" }
            if let doubleValue = Double.init(value.replacingOccurrences(of: ",", with: ".")) {
                let division = doubleValue / Constants.CaloriesPerJoule
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                let str = numberFormatter.string(from: NSNumber(floatLiteral: division))
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
            guard !value.isEmpty else { return value }
            // change any comma numbers to point numbers
            if let doubleValue = Double.init(value.replacingOccurrences(of: ",", with: ".")) {
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                let str = numberFormatter.string(from: NSNumber(floatLiteral: doubleValue))
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



