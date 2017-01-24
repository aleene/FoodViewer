//
//  NutritionFactUnit.swift
//  FoodViewer
//
//  Created by arnaud on 11/11/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

enum NutritionFactUnit: Int, CaseCountable {
    
    case None = 0
    case Joule
    case Calories
    case Kilogram
    case Gram
    case Milligram
    case Microgram
    //case Liter
    //case Milliliter
    //case Microliter
    case Percent
    
    init(_ text: String) {
        switch text {
        case Strings.Joule:
            self = .Joule
        case Strings.Calories:
            self =  .Calories
        case Strings.Kilogram:
            self =  .Kilogram
        case Strings.Gram:
            self =  .Gram
        case Strings.Milligram:
            self =  .Milligram
        case Strings.Microgram:
            self =  .Microgram
        //case Strings.Liter:
        //    self =  .Liter
        //case Strings.Milliliter:
        //    self =  .Milliliter
        //case Strings.Microliter:
        //    self =  .Microliter
        case Strings.Percent:
            self =  .Percent
        default:
            self =  .None
        }
    }

    static let caseCount = NutritionFactUnit.countCases()

    func description() -> String {
        switch self {
        case .Joule: return NSLocalizedString("Joule (J)", comment: "Energy unit")
        case .Calories: return NSLocalizedString("kCalories (kcal)", comment: "Energy unit.")
        case .Kilogram: return NSLocalizedString("kilogram (kg)", comment: "Standard weight unit multiplies by thousand.")
        case .Gram: return NSLocalizedString("gram (g)", comment: "Standard weight unit.")
        case .Milligram: return NSLocalizedString("milligram (mg)", comment: "Standard weight unit divided by thousand.")
        case .Microgram: return NSLocalizedString("microgram (µm)", comment: "Standard weight unit divided by million.")
        //case .Liter: return NSLocalizedString("liter (L)", comment: "Standard volume unit.")
        //case .Milliliter: return NSLocalizedString("milliliter (mL)", comment: "Standard volume unit divided by thousand.")
        //case .Microliter: return NSLocalizedString("microliter (µL)", comment: "Standard volume unit divided by million.")
        case .Percent: return NSLocalizedString("percentage (%)", comment: "Fraction of total by volume")
        case .None:return NSLocalizedString("none", comment: "Unitless")
        }
    }
    
    func short() -> String {
        switch self {
        case .Joule:
            return Strings.Joule
        case .Calories :
            return Strings.Calories
        case .Kilogram :
            return Strings.Kilogram
        case .Gram :
            return Strings.Gram
        case .Milligram :
            return Strings.Milligram
        case .Microgram :
            return Strings.Microgram
        //case .Liter :
        //    return Strings.Liter
        //case .Milliliter :
        //    return Strings.Milliliter
        //case .Microliter :
        //    return Strings.Microliter
        case .Percent :
            return Strings.Percent
        case .None :
            return Strings.None
        }
    }
    
    private struct Strings {
        static let Joule = "kJ"
        static let Calories = "kcal"
        static let Kilogram = "kg"
        static let Gram = " g"
        static let Milligram = "mg"
        static let Microgram = "µg"
        //static let Liter = " L"
        //static let Milliliter = "mL"
        //static let Microliter = "µL"
        static let Percent = "%"
        static let None = ""
    }

}
