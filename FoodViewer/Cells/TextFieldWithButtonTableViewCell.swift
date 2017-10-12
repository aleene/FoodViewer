//
//  TextFieldWithButtonTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 11/10/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

class TextFieldWithButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!

    @IBAction func textFieldTapped(_ sender: UITextField) {
    }
    @IBOutlet weak var button: UIButton!
    
    @IBAction func buttonTapped(_ sender: UIButton) {
    }
    
    var username: String? {
        didSet {
            textField.text = username
        }
    }
    
    var buttonText: String? {
        didSet {
            if let validText = buttonText {
                button.setTitle(validText, for: .normal)
            } else {
                button.setTitle(editMode ? "Select role" : "Role not selected", for: .normal)
            }
        }
    }
    
    var editMode: Bool = false {
        didSet {
            button.isEnabled = editMode
        }
    }
    var delegate: CompletionStatesTableViewController? = nil {
        didSet {
            textField.delegate = delegate
        }
    }
    
    private func buttonTapped() {
        delegate?.setRole()
    }
    
}
