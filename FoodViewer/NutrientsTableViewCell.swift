//
//  nutrientsTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 18/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class NutrientsTableViewCell: UITableViewCell {

    
    fileprivate struct Constants {
        static let UnknownValue = NSLocalizedString("?", comment: "Text when no value for nutritional facts have been specified.")
    }
    
    var nutritionDisplayFactItem: NutrientsTableViewController.DisplayFact? = nil {
        didSet {
            if let item = nutritionDisplayFactItem {
                itemLabel.text = item.name != nil ? item.name! : Constants.UnknownValue
                standardValueLabel.text = item.value != nil ? item.value! : Constants.UnknownValue
                standardUnitLabel.text = item.unit != nil ? item.unit!.short() : Constants.UnknownValue
            }
        }
    }
    
    var editMode: Bool = false {
        didSet {
            if editMode {
                itemLabel.backgroundColor = UIColor.groupTableViewBackground
                itemLabel.layer.cornerRadius = 5
                itemLabel.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
                itemLabel.clipsToBounds = true
            } else {
                itemLabel.layer.cornerRadius = 5
                itemLabel.backgroundColor = UIColor.white
                itemLabel.layer.borderColor = UIColor.white.cgColor
            }
        }
    }

    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var standardValueLabel: UILabel!
    @IBOutlet weak var standardUnitLabel: UILabel!

}
