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
            stateLabel.text = stateTitle != nil ? stateTitle! : "none"
        }
    }
    
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var stateSwitch: UISwitch! {
        didSet {
            stateSwitch.enabled = false
        }
    }
    
}
