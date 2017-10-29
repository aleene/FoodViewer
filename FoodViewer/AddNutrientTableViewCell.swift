//
//  AddNutrientTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 16/01/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

protocol AddNutrientCellDelegate: class {
    
    // function to let the delegate know that the switch changed
    func addNutrientTableViewCell(_ sender: AddNutrientTableViewCell, receivedTapOn button:UIButton)
}

// A cell with a button. The text of the button has to be set by the tableview

class AddNutrientTableViewCell: UITableViewCell {

    @IBOutlet weak var addNutrientButton: UIButton! {
        didSet {
            addNutrientButton.setTitle(buttonText, for: .normal )
        }
    }
    
    @IBOutlet weak var euDefaultsButton: UIButton! {
        didSet {
            euDefaultsButton.setTitle("EU set", for: .normal)
        }
    }
 
    @IBAction func euDefaultsButtonTapped(_ sender: UIButton) {
        delegate?.addNutrientTableViewCell(self, receivedTapOn: sender)
    }
    
    @IBAction func addNutrientButtonTapped(_ sender: UIButton) {    }
    
    var buttonText: String? = nil {
        didSet {
            addNutrientButton?.setTitle(buttonText, for: .normal )
        }
    }
    
    var delegate: AddNutrientCellDelegate? = nil
    
}
