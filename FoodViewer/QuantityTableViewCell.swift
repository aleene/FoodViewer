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
            textField.layer.borderWidth = 0.5
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
            textField.layer.cornerRadius = 5
            if #available(iOS 13.0, *) {
                textField.backgroundColor = .secondarySystemBackground
                textField.textColor = .secondaryLabel
                textField.layer.borderColor = UIColor.darkGray.cgColor
            } else {
                textField.layer.borderColor = UIColor.darkGray.cgColor
                textField.textColor = .black
                textField.backgroundColor = UIColor.groupTableViewBackground
            }
            textField.layer.borderColor = UIColor.darkGray.cgColor
            textField.clipsToBounds = true
            
        } else {
            textField.borderStyle = .roundedRect
            if #available(iOS 13.0, *) {
                textField.backgroundColor = .systemBackground
                textField.layer.borderWidth = 0.0
                
                textField.textColor = .label
            } else {
                textField.backgroundColor = .white
                textField.layer.borderWidth = 0.0
                textField.textColor = .black
            }
        }
    }
    
}

