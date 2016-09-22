//
//  ProductCategoryTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 10/06/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class ProductCategoryTableViewCell: UITableViewCell {

    
    var belongsToCategory: Bool = false {
        didSet {
            belongsToCategorySwitch.isOn = belongsToCategory
        }
    }
    
    var belongsToCategoryTitle: String? = nil {
        didSet {
            var belongsToCategoryLabelText = belongsToCategoryTitle != nil ? belongsToCategoryTitle! : NSLocalizedString("none", comment: "Text for a cell, when no status title has been provided, such as 'completed', etc.")
            // add a question mark
            belongsToCategoryLabelText += "?"
            belongsToCategoryLabel.text = belongsToCategoryLabelText
        }
    }
    
    @IBOutlet weak var belongsToCategoryLabel: UILabel!
    @IBOutlet weak var belongsToCategorySwitch: UISwitch! {
        didSet {
            belongsToCategorySwitch.isEnabled = false
        }
    }

}
