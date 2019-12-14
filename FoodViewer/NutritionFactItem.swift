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
    public var standard: String? = nil
    public var unit: NutritionFactUnit? = nil
    public var serving: String? = nil
    public var value: String? = nil
    public var dailyFractionPerServing: Double? = nil
    public var nutrient: Nutrient = .undefined

    public init() {
        itemName = nil
        standard = nil // this is the value normalised to standard units
        unit = nil // the unit of the value entered by the user
        serving = nil // this is calculated
        value = nil // the value entered by the user
        nutrient = .undefined
    }

    public init(name: String?, standard: String?, value: String?, serving: String?, unit: String?, nutrient: Nutrient) {
        itemName = name
        self.standard = standard
        self.serving = serving
        self.value = value
        if let validUnit = unit {
            self.unit = NutritionFactUnit(validUnit)
        }
        self.nutrient = nutrient
    }

    public init(nutrient: Nutrient, unit: NutritionFactUnit) {
        itemName = OFFplists.manager.translateNutrient(nutrient: nutrient, language:Locale.preferredLanguages[0])
        self.value = nil
        self.standard = nil
        self.serving = nil
        self.unit = unit
        self.nutrient = nutrient
    }

    public var key: String {
        return nutrient.rawValue
    }
    
    public var isValid: Bool {
        return standard != nil && !standard!.isEmpty
    }
    
    struct Constants {
        static let CaloriesPerJoule = Float(4.2)
    }
    
    public var standardAsDouble: Double? {
        if let validString = standard {
            return Double(validString)
        }
        return nil
    }

    public var gramValue: Double? {
        if let validString = standard {
            if let validUnit = unit {
                switch validUnit {
                case .Milligram:
                    if let validDouble = Double(validString) {
                        return validDouble / 1000.0
                    }
                case .Microgram:
                    if let validDouble = Double(validString) {
                        return validDouble / 1000000.0
                    }
                case .Gram:
                    return Double(validString)
                default:
                    break
                }
            }
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
    
    func valueInJoule(_ stringValue: String?) -> String {
        
        if let value = stringValue {
            guard !value.isEmpty else { return "" }
            
            let newValue = value.replacingOccurrences(of: "\u{a0}", with: "")

            if let floatValue = newValue.floatValue {
                let division = floatValue * Constants.CaloriesPerJoule
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
        return localeValue(standard, multiplier: 1.0, editMode: editMode)
    }
    
    public func localeThousandValue(editMode: Bool) -> String {
        return localeValue(standard, multiplier: 1.0, editMode: editMode)
    }

    public func localeServingValue(editMode: Bool) -> String {
        return localeValue(serving, multiplier: 1.0, editMode: editMode)
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





