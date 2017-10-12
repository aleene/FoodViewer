//
//  TranslatableStrings.swift
//  FoodViewer
//
//  Created by arnaud on 07/10/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

struct TranslatableStrings {
    
    static let A = NSLocalizedString("A", comment: "String in Segmented Control to indicate the best nutritional score level")
    static let B = NSLocalizedString("B", comment: "String in Segmented Control to indicate the second best nutritional score level")
    static let BadNutrients = NSLocalizedString("Bad nutrients", comment: "Header for a table section showing the appreciations of the bad nutrients")
    static let BeveragesCategory = NSLocalizedString("Beverages category", comment: "Cell title indicating the product belongs to the beverages category")
    static let C = NSLocalizedString("C", comment: "String in Segmented Control to indicate the thrid best nutritional score level")
    static let CheeseCategory = NSLocalizedString("Cheeses category", comment: "Cell title indicating the product belongs to the cheeses category")
    static let D = NSLocalizedString("D", comment: "String in Segmented Control to indicate the fourth best nutritional score level")
    static let E = NSLocalizedString("E", comment: "String in Segmented Control to indicate the fifth best (and last) nutritional score level")

    static let Exclude = NSLocalizedString("Exclude", comment: "String in Segmented Control to indicate whether the corresponding tag should be EXCLUDED from the search.")
    static let GoodNutrients = NSLocalizedString("Good nutrients", comment: "Header for a table section showing the appreciations of the good nutrients")

    static let Include = NSLocalizedString("Include", comment: "String in Segmented Control to indicate whether the corresponding tag should be INCLUDED in the search.")
    static let NutritionalScore = NSLocalizedString("Nutritional Score", comment: "Header for a table section showing the search for nutritional score")
    static let NutritionalScoreFrance = NSLocalizedString("Nutritional Score France", comment: "Header for a table section showing the total results France")
    static let NutritionalScoreUK = NSLocalizedString("Nutritional Score UK", comment: "Header for a table section showing the total results UK")
    static let SpecialCategories = NSLocalizedString("Special categories", comment: "Header for a table section showing the special categories")
    static let Undefined = NSLocalizedString("Undefined", comment: "String in Segmented Control to indicate the nutritional score level is undefined (and will not be used in the search)")

    struct NutritionScoreTableViewController {
        static let TitleForSectionWithBadNutrients = TranslatableStrings.BadNutrients
        static let TitleForSectionWithGoodNutrients = TranslatableStrings.GoodNutrients
        static let TitleForSectionWithExceptionCategory = TranslatableStrings.SpecialCategories
        static let TitleForSectionWithNutritionalScore = TranslatableStrings.NutritionalScore
        static let TitleForSectionWithResultUK = TranslatableStrings.NutritionalScoreUK
        static let TitleForSectionWithResultFrance = TranslatableStrings.NutritionalScoreFrance
        static let CheesesCategory = TranslatableStrings.CheeseCategory
        static let BeveragesCategory = TranslatableStrings.BeveragesCategory

    }
    
    struct SetNutritionScoreTableViewCell {
        static let Include = TranslatableStrings.Include
        static let Exclude = TranslatableStrings.Exclude
        static let A = TranslatableStrings.A
        static let B = TranslatableStrings.B
        static let C = TranslatableStrings.C
        static let D = TranslatableStrings.D
        static let E = TranslatableStrings.E
        static let Undefined = TranslatableStrings.Undefined
    }
    
    
}
