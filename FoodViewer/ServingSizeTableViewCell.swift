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
        static let ServingSizeNotAvailable = NSLocalizedString("not available", comment: "TextField text to indicate the serving size is not available")
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
            servingSizeTextField.borderStyle = .roundedRect
            servingSizeTextField.layer.borderWidth = 1.0
            servingSizeTextField.layer.borderColor = UIColor.black.cgColor
        } else {
            servingSizeTextField.borderStyle = .roundedRect
            servingSizeTextField.layer.borderWidth = 1.0
            servingSizeTextField.layer.borderColor = UIColor.white.cgColor
        }
    }

    @IBOutlet weak var servingSizeTextField: UITextField! {
        didSet {
            setTextFieldStyle()
        }
    }

    
}
