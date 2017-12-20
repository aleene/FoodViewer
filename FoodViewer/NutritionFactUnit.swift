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
        case .Joule: return NSLocalizedString("Joule (J)", comment: "Energy unit")
        case .KiloCalories: return NSLocalizedString("kcalories (kcal)", comment: "Energy unit.")
        case .Calories: return NSLocalizedString("Calores (Cal)", comment: "Energy unit.")
        case .Gram: return NSLocalizedString("gram (g)", comment: "Standard weight unit.")
        case .Milligram: return NSLocalizedString("milligram (mg)", comment: "Standard weight unit divided by thousand.")
        case .Microgram: return NSLocalizedString("microgram (µm)", comment: "Standard weight unit divided by million.")
        case .Percent: return NSLocalizedString("percentage (%)", comment: "Fraction of total by volume")
        case .None:return NSLocalizedString("none", comment: "Unitless")
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

}
