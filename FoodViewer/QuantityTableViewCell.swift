//
//  QuantityTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 27/10/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

class QuantityTableViewCell: UITableViewCell {
    
    @IBOutlet weak var textField: UITextField! {
        didSet {
            setTextFieldStyle()
        }
    }
    
    var tekst: String? = nil {
        didSet {
            textField.text = tekst
        }
    }
    
    var editMode: Bool = false {
        didSet {
            setTextFieldStyle()
        }
    }
    
    private func setTextFieldStyle() {
        if editMode {
            textField.borderStyle = .roundedRect
            textField.layer.borderWidth = 1.0
            textField.layer.borderColor = UIColor.black.cgColor
            
        } else {
            textField.borderStyle = .roundedRect
            textField.layer.borderWidth = 1.0
            textField.layer.borderColor = UIColor.white.cgColor
        }
    }
    
}

