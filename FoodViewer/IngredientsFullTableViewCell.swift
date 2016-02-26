//
//  IngredientsFullTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 24/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class IngredientsFullTableViewCell: UITableViewCell {

    
    @IBOutlet weak var ingredientsLabel: UILabel!
    
    
    var ingredients: String? = nil {
        didSet {
            if let text = ingredients {
                ingredientsLabel.text = text
            }
        }
    }

}
