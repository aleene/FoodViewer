//
//  NutrimentsAvailableTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 23/01/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

//  TableViewCell, which contains a label and a switch
//  The switch indicates whether any nutriment information is available on the package
//  Default is NO nutriment info available
//  If the cell is in editMode (true), the switch is enabled

import UIKit

protocol NutrimentsAvailableCellDelegate: class {
    
    // function to let the delegate know that the switch changed
    func nutrimentsAvailableTableViewCell(_ sender: NutrimentsAvailableTableViewCell, receivedActionOn mySwitch: UISwitch)
}


class NutrimentsAvailableTableViewCell: UITableViewCell {

    @IBOutlet weak var NutrimentsAvailableSwitch: UISwitch! {
        didSet {
            NutrimentsAvailableSwitch.isOn = hasNutrimentFacts ?? false
            NutrimentsAvailableSwitch.isEnabled = editMode
        }
    }
    
    @IBAction func NutrimentsAvailableSwitchTapped(_ sender: UISwitch) {
        delegate?.nutrimentsAvailableTableViewCell(self, receivedActionOn: sender)
    }
    
    var hasNutrimentFacts: Bool? = nil {
        didSet {
            NutrimentsAvailableSwitch?.isOn = hasNutrimentFacts ?? false
        }
    }
    
    var delegate: NutrimentsAvailableCellDelegate? = nil
    
    @IBOutlet weak var nutrimentsAvailableLabel: UILabel! {
        didSet {
            nutrimentsAvailableLabel.text = TranslatableStrings.ListedOnPackage
        }
    }
    
    var editMode = false {
        didSet {
            NutrimentsAvailableSwitch?.isEnabled = editMode
        }
    }
}
