//
//  servingSizeTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 18/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class ServingSizeTableViewCell: UITableViewCell {
    
    var servingSize: String? = nil {
        didSet {
            if let ss = servingSize {
                servingSizeTextField.text = ss
            }
        }
    }
    
    var unit: String? = nil {
        didSet {
            if let un = unit {
                unitTextField.text = un
            }
        }
    }

    @IBOutlet weak var servingSizeTextField: UITextField!
    @IBOutlet weak var unitTextField: UITextField!
}
