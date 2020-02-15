//
//  SetWarningTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 26/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

protocol SetWarningTableViewCellDelegate: class {
    
    // function to let the delegate know that the switch changed
    func setWarningTableViewCell(_ sender: SetWarningTableViewCell, receivedActionOn stateSwitch:UISwitch)
    
}

class SetWarningTableViewCell: UITableViewCell {
    
    var state: Bool = false {
        didSet {
            stateSwitch.isOn = state
        }
    }
    
    var stateTitle: String? = nil {
        didSet {
            var stateLabelText = stateTitle != nil ? stateTitle! : TranslatableStrings.None
            // add a question mark
            stateLabelText += "?"
            stateLabel.text = stateLabelText
        }
    }
    
    @IBOutlet weak var stateLabel: UILabel!
    
    @IBOutlet weak var stateSwitch: UISwitch! {
        didSet {
            stateSwitch.isEnabled = true
        }
    }
    
    @IBAction func stateSwitchToggled(_ sender: UISwitch) {
        delegate?.setWarningTableViewCell(self, receivedActionOn: stateSwitch)
    }
    
    var delegate: SetWarningTableViewCellDelegate? = nil

}
