//
//  StateTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 12/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class StateTableViewCell: UITableViewCell {

    var state: Bool = false {
        didSet {
            stateSwitch.on = state
        }
    }
    
    var stateTitle: String? = nil {
        didSet {
            stateLabel.text = stateTitle != nil ? stateTitle! : NSLocalizedString("none", comment: "Text for a cell, when no status title has been provided, such as 'completed', etc.") 
        }
    }
    
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var stateSwitch: UISwitch! {
        didSet {
            stateSwitch.enabled = false
        }
    }
    
}
