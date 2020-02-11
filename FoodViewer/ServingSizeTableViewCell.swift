//
//  servingSizeTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 18/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class ServingSizeTableViewCell: UITableViewCell {
    
   private struct Constants {
        static let ServingSizeNotAvailable = TranslatableStrings.NoServingSizeAvailable
    }
    
    var servingSize: String? = nil {
        didSet {
            servingSizeTextField?.text = ((servingSize != nil) && (!servingSize!.isEmpty)) ? servingSize! : ""
            servingSizeTextField?.placeholder = Constants.ServingSizeNotAvailable
        }
    }
    
    var editMode = false {
        didSet {
            setTextFieldStyle()
        }
    }

    
    private func setTextFieldStyle() {
        if #available(iOS 13.0, *) {
            servingSizeTextField.backgroundColor = editMode ? .secondarySystemFill : .systemBackground
            servingSizeTextField?.layer.borderColor = editMode ? UIColor.gray.cgColor : UIColor.systemBackground.cgColor
            servingSizeTextField.textColor = editMode ? .secondaryLabel : .label
        } else {
            servingSizeTextField.backgroundColor = editMode ? .groupTableViewBackground : .white
            servingSizeTextField?.layer.borderColor = editMode ? UIColor.gray.cgColor : UIColor.white.cgColor
            servingSizeTextField.textColor = .white
        }

        if editMode {
            servingSizeTextField.layer.borderWidth = 0.5
            servingSizeTextField.layer.cornerRadius = 5
            servingSizeTextField.clipsToBounds = true
        } else {
            servingSizeTextField.borderStyle = .roundedRect
            servingSizeTextField.layer.borderWidth = 0.0

        }
    }

    @IBOutlet weak var servingSizeTextField: UITextField! {
        didSet {
            setTextFieldStyle()
        }
    }

    
}
