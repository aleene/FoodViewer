//
//  NutritionFactItem.swift
//  FoodViewer
//
//  Created by arnaud on 10/04/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

public struct NutritionFactItem: Hashable, Equatable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(nutrient.key)
    }

    // Mark: Equatable
    public static func ==(lhs: NutritionFactItem, rhs: NutritionFactItem) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    public var itemName: String? = nil
    /// The value normalised to standard units (100 g or 100 ml)
    public var standard: String? = nil
    /// The standard unit as used by OFF
    public var standardUnit: NutritionFactUnit? = nil
    /// The value per serving as calculated by OFF
    public var serving: String? = nil
    /// The value entered by the user  in FoodViewer.
    public var valueEdited: String? = nil
    /// The unit entered by the user  in FoodViewer
    public var valueUnitEdited: NutritionFactUnit? = nil
    /// The value the user originally entered provided by OFF
    public var value: String? = nil
    /// The unit of the value  the user originally entered provided by OFF
    public var valueUnit: NutritionFactUnit? = nil
    /// The nutrient the values and units apply to
    public var nutrient: Nutrient = .undefined

    public var valuePair: (String?, NutritionFactUnit) {
        return (value, valueUnit ?? .none)
    }
    
    public var editedValuePair: (String?, NutritionFactUnit) {
        return (valueEdited, valueUnitEdited ?? .none)
    }

    public var editedValuePairAsDouble: (Double?, NutritionFactUnit) {
        return (valueAsDouble, valueUnitEdited ?? .none)
    }

    public var standardPair: (String?, NutritionFactUnit) {
        return (standard, standardUnit ?? .none)
    }

    public var servingPair: (String?, NutritionFactUnit) {
        return (serving, standardUnit ?? .none)
    }

    public init() { }

// MARK: - initialisers
    
    public init(name: String?, standard: String?, standardUnit: String?, value: String?, valueUnit: String?, serving: String?, valueEdited: String?, valueUnitEdited: String?, nutrient: Nutrient) {
        itemName = name
        self.standard = standard
        self.serving = serving
        self.value = value
        self.valueEdited = valueEdited
        if let validUnit = standardUnit {
            self.standardUnit = NutritionFactUnit(validUnit)
        }
        if let validUnit = standardUnit {
            self.valueUnitEdited = NutritionFactUnit(validUnit)
        }
        if let validUnit = valueUnit {
            self.valueUnit = NutritionFactUnit(validUnit)
        }
        self.nutrient = nutrient
    }

    public init(nutrient: Nutrient, unit: NutritionFactUnit) {
        itemName = OFFplists.manager.translateNutrient(nutrient: nutrient, language:Locale.preferredLanguages[0])
        self.value = nil
        self.standard = nil
        self.serving = nil
        self.standardUnit = unit
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

    public var servingAsDouble: Double? {
        if let validString = serving {
            return Double(validString)
        }
        return nil
    }

    public var valueAsDouble: Double? {
        if let validString = value {
            return Double(validString)
        }
        return nil
    }

    public var valueEditedAsDouble: Double? {
        if let validString = valueEdited {
            return Double(validString)
        }
        return nil
    }

    public var standardGramValue: Double? {
        guard let divider = standardUnit?.divider else { return nil }
        if let validDouble = standardAsDouble {
            return validDouble / Double(divider)
        }
        return nil
    }
    
    public var valueGramValue: Double? {
        guard let divider = valueUnit?.divider else { return nil }
        if let validDouble = valueAsDouble {
            return validDouble / Double(divider)
        }
        return nil
    }

    /// Transforms the valued edited in FoodViewer to Gram
    public var valueEditedGramValue: Double? {
        guard let divider = valueUnitEdited?.divider else { return nil }
        if let validDouble = valueEditedAsDouble {
            return validDouble / Double(divider)
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

    public func localeStandardValue(editMode: Bool) -> (String?, NutritionFactUnit) {
        return localeValue(standard, multiplier: 1.0, editMode: editMode)
    }
    
    public func localeThousandValue(editMode: Bool) -> (String?, NutritionFactUnit) {
        return localeValue(standard, multiplier: 10.0, editMode: editMode)
    }

    public func localeServingValue(editMode: Bool) -> (String?, NutritionFactUnit) {
        return localeValue(serving, multiplier: 1.0, editMode: editMode)
    }

    fileprivate func localeValue(_ stringValue: String?, multiplier: Float, editMode: Bool) -> (String?, NutritionFactUnit) {
        // a percentage can not be transformed to a daily value
        if let validStandardUnit = standardUnit,
                validStandardUnit == .percent
                || validStandardUnit == .dailyValuePercent {
            return (stringValue, validStandardUnit)
        }

        if let value = stringValue {
            // an empty string does not have to be analysed
            guard !value.isEmpty else { return ("", standardUnit ?? .none) }
            // remove any unicode a0 (non-breaking space)
            let newValue = value.replacingOccurrences(of: "\u{a0}", with: "")

            // accept numbers with a , or . separator
            if var floatValue = newValue.floatValue {
                floatValue = floatValue * multiplier
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                numberFormatter.maximumSignificantDigits = 4
                numberFormatter.usesGroupingSeparator = !editMode
                return (numberFormatter.string(from: NSNumber(value: floatValue)), standardUnit ?? .none)
            } else {
                return (value, standardUnit ?? .none)
            }
        }
        return ("", standardUnit ?? .none)

    }
    
    var dailyValuePercentage: (String?, NutritionFactUnit) {
        // a percentage can not be transforemd to a daily value
        if let validStandardUnit = standardUnit,
                validStandardUnit == .percent
                || validStandardUnit == .dailyValuePercent {
            return (standard, validStandardUnit)
        }
        
        guard var validServing = serving else { return ("?!?", .none) }
        
        // the reference values are in in kJ, so any calories must be converted
        if nutrient == .energy
            || nutrient == .energyKcal
            || nutrient == .energyFromFat {
            if let validUnit = standardUnit,
                validUnit == .calories || validUnit == .kiloCalories {
                validServing = valueInJoule(validServing)
            }
        }

        // sometimes there are comma's instead of dots used in the number
        let servingWithDots = validServing.replacingOccurrences(of: ",", with: ".")

        let dailyFractionPerServing = ReferenceDailyIntakeList.manager.dailyValue(serving: servingWithDots, nutrient: nutrient)
        
        if let validValue = dailyFractionPerServing {
            // convert standard value to a number in the users locale
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumFractionDigits = 1
            let validValue: Double = Double(validValue) * 100.0
            if let returnString = numberFormatter.string(from: NSNumber(value: validValue)) {
                return (returnString, .dailyValuePercent)
            }
        }
        return ("?!?", .none)
    }

}



