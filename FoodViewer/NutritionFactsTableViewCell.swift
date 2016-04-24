//
//  NutritionFactsTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 01/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class NutritionFactsTableViewCell: UITableViewCell {

    private struct Constants {
        static let UnknownValue = " "
    }
    
    var product: FoodProduct? = nil
    
    var nutritionFactItem: NutritionFactItem? = nil {
        didSet {
            if let item = nutritionFactItem {
                    itemLabel.text = item.itemName != nil ? item.itemName! : Constants.UnknownValue
                    standardValueLabel.text = item.standardValue != nil ? item.standardValue! : Constants.UnknownValue
                    standardUnitLabel.text = item.standardValueUnit != nil ? item.standardValueUnit! : Constants.UnknownValue
            }
        }
    }
    
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var standardValueLabel: UILabel!
    @IBOutlet weak var standardUnitLabel: UILabel!
    
}
