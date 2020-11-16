//
//  NutritionFactUnit.swift
//  FoodViewer
//
//  Created by arnaud on 11/11/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

public enum NutritionFactUnit {
    
    case gram
    case milligram
    case microgram
    case joule
    case calories // big calories?
    case kiloCalories
    case percent
    case dailyValuePercent
    case none
    
    public init(_ text: String) {
        switch text {
        case Strings.Joule:
            self = .joule
        case Strings.Calories:
            self =  .calories
        case Strings.KiloCalories:
            self =  .kiloCalories
        case Strings.Gram:
            self =  .gram
        case Strings.Milligram:
            self =  .milligram
        case Strings.Microgram:
            self =  .microgram
        case Strings.Percent:
            self =  .percent
        case Strings.DailyValuePercent:
            self =  .percent
        case Strings.None:
            self =  .none
        default:
            self = .none
        }
    }
    
    public static func units(for energy:Bool) -> [NutritionFactUnit] {
        if energy {
            return [.joule, .kiloCalories, .calories]
        } else {
            return [.gram, .milligram, .microgram, .percent, .dailyValuePercent, .none]
        }
    }
    
    public static func value(for row: Int, and key:String) -> Int {
        // is this an energy nutrient?
        if key.hasPrefix(LocalizedEnergy.prefixKey) {
            // This is an energy nutriment
            return row + 3
        } else {
            return row <= 2 ? row : row + 2
        }
    }
    
    /// The divider required to normalize the unit
    public var divider: Int {
        switch self {
        case .milligram:
            return 1000
        case .microgram:
            return 1000000
        default:
            return 1
        }
    }
    
    public var description: String {
        switch self {
        case .joule: return TranslatableStrings.Joule
        case .kiloCalories: return TranslatableStrings.KiloCalorie
        case .calories: return TranslatableStrings.Calories
        case .gram: return TranslatableStrings.Gram
        case .milligram: return TranslatableStrings.Milligram
        case .microgram: return TranslatableStrings.Microgram
        case .percent: return TranslatableStrings.Percentage
        case .dailyValuePercent: return TranslatableStrings.DailyValue
        case .none: return TranslatableStrings.None
        }
    }
    
    public var short: String {
        switch self {
        case .joule:
            return Strings.Joule
        case .calories:
            return Strings.Calories
        case .kiloCalories:
            return Strings.KiloCalories
        case .gram:
            return Strings.Gram
        case .milligram:
            return Strings.Milligram
        case .microgram:
            return Strings.Microgram
        case .percent:
            return Strings.Percent
        case .dailyValuePercent:
            return Strings.DailyValuePercent
        case .none:
            return Strings.None
        }
    }
    
    public func short(key: String) -> String {
        // is this an energy nutrient?
        if key.hasPrefix(LocalizedEnergy.prefixKey) {
            switch self {
            case .joule:
                return Strings.Joule
            case .calories :
                return Strings.Calories
            case .kiloCalories :
                return Strings.KiloCalories
            case .percent :
                return Strings.Percent
            default :
                return Strings.None
            }
        } else {
            switch self {
            case .gram:
                return Strings.Gram
            case .milligram:
                return Strings.Milligram
            case .microgram:
                return Strings.Microgram
            case .percent:
                return Strings.Percent
            case .dailyValuePercent:
                return Strings.DailyValuePercent
            default :
                return Strings.None
            }
        }
    }
    
    private struct Strings {
        static let Joule = "kJ"
        static let Calories = "Cal"
        static let KiloCalories = "kcal"
        static let Gram = "g"
        static let Milligram = "mg"
        static let Microgram = "µg"
        static let Percent = "%"
        static let DailyValuePercent = "%DV"
        static let None = "-"
    }

    // assume we start with grams
    static func normalize(_ value: String?) -> (String?, NutritionFactUnit) {
        var newValue: String? = nil
        var newUnit: NutritionFactUnit = .gram
        
        guard value != nil else { return (nil, .gram) }
        
        if var doubleValue = Double(value!) {
            // the value can be converted to a number
            if doubleValue < 0.99 {
                //change to the milli version
                doubleValue = doubleValue * 1000.0
                if doubleValue < 0.99 {
                    // change to the microversion
                    doubleValue = doubleValue * 1000.0
                    // we use only the values standerdized on g
                    if doubleValue < 0.99 {
                        // this is nanogram, probably the value is just 0
                        newUnit = .gram
                    } else {
                        newUnit = .microgram
                    }
                } else {
                    // more than 1 milligram, use milligram
                    newUnit = .milligram
                }
            } else {
                // larger than 1, use gram
                newUnit = .gram
            }
            // print("standard: \(key) \(doubleValue) " + nutritionItem.standardValueUnit! )
            newValue = "\(doubleValue)"
        } else {
            // not a number, maybe some text
            newValue = value
        }
        
        return (newValue, newUnit)
    }
    
    public var isNone: Bool {
        switch self {
        case .none:
            return true
        default:
            return false
        }
    }

}
