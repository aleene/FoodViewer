//
//  IngredientsTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 01/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class IngredientsTableViewCell: UITableViewCell {
    
    private struct Constants {
        static let NoIngredientsText = NSLocalizedString("No ingredients listed.", comment: "Text to indicate that no ingredients are present in the product data.") 
        static let IngredientsText = NSLocalizedString("There are %@ ingredients.", comment: "Text to indicate the number of ingredients in the product.")
        static let IngredientsOneText = NSLocalizedString("There is 1 ingredient.", comment: "Text to indicate that there is one ingredient in the product.")
    }

    var product: FoodProduct? = nil {
        didSet {
            if let number = product?.numberOfIngredients  {
                let formatter = NSNumberFormatter()
                formatter.numberStyle = .DecimalStyle
                
                ingredientsLabel.text = Int(number) == 1 ? Constants.IngredientsText : String(format:Constants.IngredientsText, formatter.stringFromNumber(Int(number)!)! )
            } else {
                ingredientsLabel.text = Constants.NoIngredientsText
            }
        }
    }

    @IBOutlet weak var ingredientsLabel: UILabel!
    
}
