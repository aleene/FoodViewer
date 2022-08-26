//
//  AddNutrientTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 16/01/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

protocol AddNutrientCellDelegate: AnyObject {
    
    /// function to let the delegate know that the EU nutrient set button has been tapped
    func addEUNutrientSetTableViewCell(_ sender: AddNutrientTableViewCell, receivedTapOn button:UIButton)
    /// function to let the delegate know that the US nutrient set button has been tapped
    func addUSNutrientSetTableViewCell(_ sender: AddNutrientTableViewCell, receivedTapOn button:UIButton)
    
    func addNutrientTableViewCell(_ sender:AddNutrientTableViewCell, tappedOn button:UIButton)
}

// A cell with a button. The text of the button has to be set by the tableview

class AddNutrientTableViewCell: UITableViewCell {

    @IBOutlet weak var addNutrientButton: UIButton! {
        didSet {
            addNutrientButton.setTitle(buttonText, for: .normal )
        }
    }
    
    @IBOutlet weak var euSetButton: UIButton! {
        didSet {
            euSetButton.setTitle(TranslatableStrings.EUSet, for: .normal)
        }
    }
    
    @IBOutlet weak var usSetButton: UIButton! {
        didSet {
            usSetButton.setTitle(TranslatableStrings.USSet, for: .normal)
        }
    }

 
    @IBAction func euDefaultsButtonTapped(_ sender: UIButton) {
        delegate?.addEUNutrientSetTableViewCell(self, receivedTapOn: sender)
    }

    @IBAction func usDefaultsButtonTapped(_ sender: UIButton) {
        delegate?.addUSNutrientSetTableViewCell(self, receivedTapOn: sender)
    }

    @IBAction func addNutrientButtonTapped(_ sender: UIButton) {
        delegate?.addNutrientTableViewCell(self, tappedOn: sender)
    }
    
    var buttonText: String? = nil {
        didSet {
            addNutrientButton?.setTitle(buttonText, for: .normal )
        }
    }
    
    var delegate: AddNutrientCellDelegate? = nil
    
}
