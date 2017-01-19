//
//  AddNutrientTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 16/01/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

// A cell with a button. The text of the button has to be set by the tableview

class AddNutrientTableViewCell: UITableViewCell {

    @IBOutlet weak var addNutrientButton: UIButton! {
        didSet {
            addNutrientButton.setTitle(buttonText, for: .normal )
        }
    }
 
    var buttonText: String? = nil {
        didSet {
            addNutrientButton?.setTitle(buttonText, for: .normal )
        }
    }
}
