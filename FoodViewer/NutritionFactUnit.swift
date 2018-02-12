//
//  NutritionFactUnit.swift
//  FoodViewer
//
//  Created by arnaud on 11/11/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

public enum NutritionFactUnit {
    
    case Gram
    case Milligram
    case Microgram
    case Joule
    case Calories
    case KiloCalories
    case Percent
    case None
    
    public init(_ text: String) {
        switch text {
        case Strings.Joule:
            self = .Joule
        case Strings.Calories:
            self =  .Calories
        case Strings.KiloCalories:
            self =  .KiloCalories
        case Strings.Gram:
            self =  .Gram
        case Strings.Milligram:
            self =  .Milligram
        case Strings.Microgram:
            self =  .Microgram
        case Strings.Percent:
            self =  .Percent
        default:
            self =  .None
        }
    }
    
    public static func units(for energy:Bool) -> [NutritionFactUnit] {
        if energy {
            return [.Joule, .KiloCalories, .Calories]
        } else {
            return [.Gram, .Milligram, .Microgram, .Percent, .None]
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
    
    func description() -> String {
        switch self {
        case .Joule: return TranslatableStrings.Joule
        case .KiloCalories: return TranslatableStrings.KiloCalorie
        case .Calories: return TranslatableStrings.Calories
        case .Gram: return TranslatableStrings.Gram
        case .Milligram: return TranslatableStrings.Milligram
        case .Microgram: return TranslatableStrings.Microgram
        case .Percent: return TranslatableStrings.Percentage
        case .None: return TranslatableStrings.None
        }
    }
    
    public func short() -> String {
        switch self {
        case .Joule:
            return Strings.Joule
        case .Calories :
            return Strings.Calories
        case .KiloCalories :
            return Strings.KiloCalories
        case .Gram :
            return Strings.Gram
        case .Milligram :
            return Strings.Milligram
        case .Microgram :
            return Strings.Microgram
        case .Percent :
            return Strings.Percent
        case .None :
            return Strings.None
        }
    }
    
    public func short(key: String) -> String {
        // is this an energy nutrient?
        if key.hasPrefix(LocalizedEnergy.prefixKey) {
            switch self {
            case .Joule:
                return Strings.Joule
            case .Calories :
                return Strings.Calories
            case .KiloCalories :
                return Strings.KiloCalories
            case .Percent :
                return Strings.Percent
            default :
                return Strings.None
            }
        } else {
            switch self {
            case .Gram :
                return Strings.Gram
            case .Milligram :
                return Strings.Milligram
            case .Microgram :
                return Strings.Microgram
            case .Percent :
                return Strings.Percent
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
        static let None = "-"
    }

    // assume we start with grams
    static func normalize(_ value: String?) -> (String?, NutritionFactUnit) {
        var newValue: String? = nil
        var newUnit: NutritionFactUnit = .Gram
        
        guard value != nil else { return (nil, NutritionFactUnit.Gram) }
        
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
                        newUnit = NutritionFactUnit.Gram
                    } else {
                        newUnit = NutritionFactUnit.Microgram
                    }
                } else {
                    // more than 1 milligram, use milligram
                    newUnit = NutritionFactUnit.Milligram
                }
            } else {
                // larger than 1, use gram
                newUnit = NutritionFactUnit.Gram
            }
            // print("standard: \(key) \(doubleValue) " + nutritionItem.standardValueUnit! )
            newValue = "\(doubleValue)"
        } else {
            // not a number, maybe some text
            newValue = value
        }
        
        return (newValue, newUnit)
    }

}
