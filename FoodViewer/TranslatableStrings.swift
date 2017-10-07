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
    static let C = NSLocalizedString("C", comment: "String in Segmented Control to indicate the thrid best nutritional score level")
    static let D = NSLocalizedString("D", comment: "String in Segmented Control to indicate the fourth best nutritional score level")
    static let E = NSLocalizedString("E", comment: "String in Segmented Control to indicate the fifth best (and last) nutritional score level")
    static let Exclude = NSLocalizedString("Exclude", comment: "String in Segmented Control to indicate whether the corresponding tag should be EXCLUDED from the search.")
    static let Include = NSLocalizedString("Include", comment: "String in Segmented Control to indicate whether the corresponding tag should be INCLUDED in the search.")
    static let Undefined = NSLocalizedString("Undefined", comment: "String in Segmented Control to indicate the nutritional score level is undefined (and will not be used in the search)")

    
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
