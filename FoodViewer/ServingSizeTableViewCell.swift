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
    
    @IBOutlet weak var servingSizeTextField: UITextField!
}
