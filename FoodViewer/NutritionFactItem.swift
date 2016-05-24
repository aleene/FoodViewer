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
    var standardValueUnit: String? = nil
    var servingValue: String? = nil
    var servingValueUnit: String? = nil
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
        standardValueUnit = unit
        servingValueUnit = unit
        self.key = key
    }

    func valid() -> Bool {
        return standardValue != nil && !standardValue!.isEmpty
    }
    
    struct Constants {
        static let CaloriesPerJoule = 4.2
    }

    func valueInCalories(stringValue: String?) -> String {
        
        if !stringValue!.isEmpty {
            // convert standard value to a number
            let value = Double(stringValue!)
            let numberFormatter = NSNumberFormatter()
            numberFormatter.numberStyle = .DecimalStyle
            return String(numberFormatter.stringFromNumber(value! / Constants.CaloriesPerJoule)!)
        }
        return ""
    }
    func localeStandardValue() -> String {
        return localeValue(standardValue)
    }
    
    func localeServingValue() -> String {
        return localeValue(servingValue)
    }

    private func localeValue(value: String?) -> String {

        if let validValue = value {

            if !validValue.isEmpty {

                // convert standard value to a number in the users locale
                if let valueDouble = Double(validValue) {

                    let numberFormatter = NSNumberFormatter()
                    numberFormatter.numberStyle = .DecimalStyle
                    if let returnString = numberFormatter.stringFromNumber(valueDouble) {
                        return returnString
                    }
                }

            }
            return validValue
        }

        return ""
    }

    func localeDailyValue() -> String {
        
        if let validValue = dailyFractionPerServing {
            
            // convert standard value to a number in the users locale
            let numberFormatter = NSNumberFormatter()
            numberFormatter.numberStyle = .PercentStyle
            if let returnString = numberFormatter.stringFromNumber(NSNumber.init(double: validValue)) {
                return returnString
            }
        }
        return ""
    }

}



