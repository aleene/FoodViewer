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
    public var nutrient: Nutrient = .undefined

    public init() {
        itemName = nil
        standardValue = nil
        standardValueUnit = nil
        servingValue = nil
        servingValueUnit = nil
        nutrient = .undefined
    }

    public init(name: String?, standard: String?, serving: String?, unit: String?, nutrient: Nutrient) {
        itemName = name
        standardValue = standard
        servingValue = serving
        if let validUnit = unit {
            standardValueUnit = NutritionFactUnit(validUnit)
            servingValueUnit = NutritionFactUnit(validUnit)
        }
        self.nutrient = nutrient
    }

    public init(nutrient: Nutrient, unit: NutritionFactUnit) {
        itemName = OFFplists.manager.translateNutrient(nutrient: nutrient, language:Locale.preferredLanguages[0])
        standardValue = nil
        servingValue = nil
        standardValueUnit = unit
        servingValueUnit = unit
        self.nutrient = nutrient
    }

    public var key: String {
        return nutrient.rawValue
    }
    
    public var isValid: Bool {
        return standardValue != nil && !standardValue!.isEmpty
    }
    
    struct Constants {
        static let CaloriesPerJoule = Float(4.2)
    }
    
    public var value: Double? {
        if let validString = standardValue {
            return Double(validString)
        }
        return nil
    }

    func valueInCalories(_ stringValue: String?) -> String {
        
        if let value = stringValue {
            guard !value.isEmpty else { return "" }
            
            let newValue = value.replacingOccurrences(of: "\u{a0}", with: "")

            if let floatValue = newValue.floatValue {
                let division = floatValue / Constants.CaloriesPerJoule
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                numberFormatter.maximumSignificantDigits = 4
                let str = numberFormatter.string(from: NSNumber(floatLiteral: Double(division)))
                guard (str != nil) else { return "" }
                return str!
            } else {
                return value
            }
        }
        return ""
    }
    
    public func localeStandardValue(editMode: Bool) -> String {
        return localeValue(standardValue, multiplier: 1.0, editMode: editMode)
    }
    
    public func localeThousandValue(editMode: Bool) -> String {
        return localeValue(standardValue, multiplier: 1.0, editMode: editMode)
    }

    public func localeServingValue(editMode: Bool) -> String {
        return localeValue(servingValue, multiplier: 1.0, editMode: editMode)
    }

    fileprivate func localeValue(_ stringValue: String?, multiplier: Float, editMode: Bool) -> String {

        if let value = stringValue {
            // an empty string does not have to be analysed
            guard !value.isEmpty else { return "" }
            // remove any unicode a0 (non-breaking space)
            let newValue = value.replacingOccurrences(of: "\u{a0}", with: "")

            // accept numbers with a , or . separator
            if var floatValue = newValue.floatValue {
                floatValue = floatValue * multiplier
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                numberFormatter.maximumSignificantDigits = 4
                numberFormatter.usesGroupingSeparator = !editMode
                return numberFormatter.string(from: NSNumber(value: floatValue)) ?? ""
            } else {
                return value
            }
        }
        return ""

    }
    
    var localeDailyValue: String {
        
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





