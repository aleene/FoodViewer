//
//  nutrientsTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 18/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class NutrientsTableViewCell: UITableViewCell {

    
    private struct Constants {
        static let UnknownValue = NSLocalizedString("?", comment: "Text when no value for nutritional facts have been specified.")
        static let SaltKey = "Salt"
        static let SodiumKey = "Sodium"
    }
    
    var nutritionFactItem: FoodProduct.NutritionFactItem? = nil {
        didSet {
            if let item = nutritionFactItem {
                if item.itemName! == Constants.SaltKey {
                    switch showSaltOrSodium {
                    case .Sodium:
                        return
                    default:
                        break
                    }
                } else if item.itemName! == Constants.SodiumKey {
                    switch showSaltOrSodium {
                    case .Salt:
                        return
                    default:
                        break
                    }
                }
                itemLabel.text = item.itemName != nil ? item.itemName! : Constants.UnknownValue
                standardValueLabel.text = item.standardValue != nil ? item.standardValue! : Constants.UnknownValue
                standardUnitLabel.text = item.standardValueUnit != nil ? item.standardValueUnit! : Constants.UnknownValue
            }
        }
    }
    
    var showSaltOrSodium: NatriumChloride = .Salt
    
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var standardValueLabel: UILabel!
    @IBOutlet weak var standardUnitLabel: UILabel!

}
