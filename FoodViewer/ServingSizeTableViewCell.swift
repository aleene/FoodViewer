//
//  servingSizeTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 18/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class ServingSizeTableViewCell: UITableViewCell {
    
    struct Constants {
        static let ServingSizeNotAvailable = NSLocalizedString("not available", comment: "TextField text to indicate the serving size is not available")
    }
    var servingSize: String? = nil {
        didSet {
            servingSizeTextField?.text = ((servingSize != nil) && (!servingSize!.isEmpty)) ? servingSize! : Constants.ServingSizeNotAvailable
        }
    }
    
    @IBOutlet weak var servingSizeTextField: UITextField!
    
}
