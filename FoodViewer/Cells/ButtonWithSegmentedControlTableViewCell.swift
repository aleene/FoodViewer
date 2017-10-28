//
//  ButtonWithSegmentedControlTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 07/10/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

protocol ButtonWithSegmentedControlCellDelegate: class {
    // function to let the delegate know that the switch changed
    func buttonTapped(_ sender: ButtonWithSegmentedControlTableViewCell, button: UIButton)
    func segmentedControlToggled(_ sender: ButtonWithSegmentedControlTableViewCell, segmentedControl: UISegmentedControl)
}

class ButtonWithSegmentedControlTableViewCell: UITableViewCell {

    @IBOutlet weak var button: UIButton! {
        didSet {
            button.setTitle(buttonText, for: .normal)
        }
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        delegate?.buttonTapped(self, button: sender)
    }
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func segmentedControlTapped(_ sender: UISegmentedControl) {
        delegate?.segmentedControlToggled(self, segmentedControl: sender)
    }
    
    var buttonText: String? = nil {
        didSet {
            if let validText = buttonText {
                var elements = validText.characters.split(separator: " ").map(String.init)
                if elements.count > 0 {
                    segmentedControl.setTitle("not " + elements.last!, forSegmentAt: 0)
                    segmentedControl.setTitle(elements.last, forSegmentAt: 1)
                    elements.remove(at: elements.count - 1)
                    button.setTitle(elements.joined(separator: " "), for: .normal)
                }
            } else {
                if editMode {
                    button.setTitle(TranslatableStrings.SelectCompletionStatus, for: .normal)
                } else {
                    button.setTitle(TranslatableStrings.NotSet, for: .normal)
                }
            }
        }
    }
    
    var editMode: Bool = false {
        didSet {
            button.isEnabled = editMode
            segmentedControl.isEnabled = editMode && buttonText != nil
        }
    }
    
    var isCompleted: Bool = true {
        didSet {
            segmentedControl.selectedSegmentIndex = isCompleted ? 1 : 0
        }
    }
    
    var delegate: ButtonWithSegmentedControlCellDelegate? = nil
    
}
