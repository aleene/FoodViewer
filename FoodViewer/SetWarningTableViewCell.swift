//
//  SetWarningTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 26/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class SetWarningTableViewCell: UITableViewCell {
    
    var state: Bool = false {
        didSet {
            stateSwitch.isOn = state
        }
    }
    
    var stateTitle: String? = nil {
        didSet {
            var stateLabelText = stateTitle != nil ? stateTitle! : NSLocalizedString("none", comment: "Text for a cell, when no status title has been provided, such as 'completed', etc.")
            // add a question mark
            stateLabelText += "?"
            stateLabel.text = stateLabelText
        }
    }
    
    @IBOutlet weak var stateLabel: UILabel!
    
    @IBOutlet weak var stateSwitch: UISwitch! {
        didSet {
            stateSwitch.isEnabled = false
        }
    }
    
}
