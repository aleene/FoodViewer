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
        static let NoIngredientsText = "No ingredients listed."
        static let IngredientsPreText = "There are "
        static let IngredientsPostText = " ingredients."
    }

    var product: FoodProduct? = nil {
        didSet {
            if let number = product?.numberOfIngredients  {
                ingredientsLabel.text = Constants.IngredientsPreText + number + Constants.IngredientsPostText
            } else {
                ingredientsLabel.text = Constants.NoIngredientsText
            }
        }
    }

    @IBOutlet weak var ingredientsLabel: UILabel!
    
}
