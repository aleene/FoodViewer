//
//  QuantityTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 27/10/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

protocol QuantityTableViewCellDelegate: class {
    
    // function to let the delegate know that the button was tapped
    func quantityTableViewCell(_ sender: QuantityTableViewCell, receivedTapOn button:UIButton)
    
}

class QuantityTableViewCell: UITableViewCell {
    
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.clearButtonMode = .whileEditing
            textField.delegate = delegate
            textField.tag = tag
            setTextFieldStyle()
        }
    }
    
    @IBOutlet weak var eButton: UIButton! {
        didSet {
            eButton.setTitle("+ ℮", for: .normal)
            eButton.isEnabled = editMode
            eButton.isHidden = !editMode
        }
    }
    

    @IBAction func eButtonPressed(_ sender: UIButton) {
        delegate?.quantityTableViewCell(self, receivedTapOn: eButton)
    }
    
    var tekst: String? = nil {
        didSet {
            textField.text = tekst
        }
    }
    
    var editMode: Bool = false {
        didSet {
            eButton.isEnabled = editMode
            eButton.isHidden = !editMode
            setTextFieldStyle()
        }
    }
    
    var delegate: IdentificationTableViewController? = nil {
        didSet {
            textField?.delegate = delegate
        }
    }
    
    override var tag: Int {
        didSet {
            textField?.tag = tag
        }
    }
    
    private func setTextFieldStyle() {
        if editMode {
            textField.layer.borderWidth = 0.5
            textField.layer.cornerRadius = 5
            textField.borderStyle = .roundedRect
            if #available(iOS 13.0, *) {
                textField.backgroundColor = .secondarySystemBackground
                textField.textColor = .secondaryLabel
            } else {
                textField.textColor = .black
                textField.backgroundColor = .groupTableViewBackground
            }
            textField.clipsToBounds = true
            
        } else {
            textField.layer.borderWidth = 0.0
            textField.borderStyle = .none
            if #available(iOS 13.0, *) {
                textField.backgroundColor = .systemBackground
                textField.textColor = .label
            } else {
                textField.backgroundColor = .white
                textField.textColor = .black
            }
        }
    }
    
}

