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
        if editMode {
            servingSizeTextField.layer.borderWidth = 0.5
            servingSizeTextField.backgroundColor = UIColor.groupTableViewBackground
            servingSizeTextField.layer.cornerRadius = 5
            servingSizeTextField.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
            servingSizeTextField.clipsToBounds = true
        } else {
            servingSizeTextField.borderStyle = .roundedRect
            servingSizeTextField.layer.borderWidth = 0.5
            servingSizeTextField.layer.borderColor = UIColor.white.cgColor
            servingSizeTextField.backgroundColor = UIColor.white

        }
    }

    @IBOutlet weak var servingSizeTextField: UITextField! {
        didSet {
            setTextFieldStyle()
        }
    }

    
}
