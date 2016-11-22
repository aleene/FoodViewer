//
//  ExpirationDateTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 21/11/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class ExpirationDateTableViewCell: UITableViewCell {

    var date: Date? = Date.init(timeIntervalSinceNow: 0.0) {
        didSet {
            setTextFieldStyle()
        }
    }

    var editMode: Bool = false {
        didSet {
            if editMode != oldValue {
                setTextFieldStyle()
            }
        }
    }

    private func setTextFieldStyle() {
        if expirationDateTextField != nil {
            if let validDate = date {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                expirationDateTextField.text = formatter.string(from: validDate as Date)
            }
            if editMode {
                expirationDateTextField.borderStyle = .roundedRect
                expirationDateTextField.layer.borderWidth = 1.0
                expirationDateTextField.layer.borderColor = UIColor.black.cgColor
                expirationDateTextField.isEnabled = true
                expirationDateButton.isHidden = false
            } else {
                expirationDateTextField.borderStyle = .roundedRect
                expirationDateTextField.layer.borderWidth = 1.0
                expirationDateTextField.layer.borderColor = UIColor.white.cgColor
                expirationDateTextField.isEnabled = false
                expirationDateButton.isHidden = true
            }
        }
    }

    @IBOutlet weak var expirationDateButton: UIButton!
    
    @IBOutlet weak var expirationDateTextField: UITextField! {
        didSet {
            setTextFieldStyle()
        }
    }
    
}
