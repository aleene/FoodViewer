//
//  TextFieldWithButtonTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 11/10/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

protocol TextFieldWithButtonCellDelegate: AnyObject {
    func textFieldWithButtonTableViewCell(_ sender: TextFieldWithButtonTableViewCell, receivedActionOn button:UIButton)
}

class TextFieldWithButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!

    @IBAction func textFieldTapped(_ sender: UITextField) {
    }
    @IBOutlet weak var button: UIButton!
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        delegate?.textFieldWithButtonTableViewCell(self, receivedActionOn:sender)

    }
    
    var username: String? {
        didSet {
            textField.text = username
            if username == nil {
                textField.placeholder = TranslatableStrings.EnterContributorName
                button.isEnabled = false
            } else if username!.isEmpty {
                button.isEnabled = false
            } else {
                button.isEnabled = true
            }
        }
    }
    
    var buttonText: String? {
        didSet {
            if let validText = buttonText {
                button.setTitle(validText, for: .normal)
            } else {
                button.setTitle(editMode ? TranslatableStrings.SelectRole : TranslatableStrings.RoleNotSelected, for: .normal)
            }
        }
    }
    
    var editMode: Bool = false {
        didSet {
            button.isEnabled = editMode
        }
    }
    var delegate: TextFieldWithButtonCellDelegate? = nil {
        didSet {
            if delegate is UITextFieldDelegate {
                textField.delegate = delegate as? UITextFieldDelegate
            } else {
                assert(true, "TextFieldWithButtonTableViewCell Error: The TexField delegate has not been set up.")
            }
        }
    }
    
}
