//
//  IngredientsTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 01/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class IngredientsTableViewCell: UITableViewCell {
    
    var product: FoodProduct? = nil {
        didSet {
            if let ingredients = product?.ingredients {
                // TBD what about allergen ingredients?
                ingredientsLabel.text = ingredients
            }
        }
    }

    @IBOutlet weak var ingredientsLabel: UILabel!
    
}
