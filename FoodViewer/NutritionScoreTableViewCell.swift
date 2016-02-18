//
//  NutritionScoreTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 01/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class NutritionScoreTableViewCell: UITableViewCell {

    var product: FoodProduct? = nil {
        didSet {
            if let score = product?.nutritionScore {
                for (item, level) in score {
                    switch item {
                    case .Fat:
                        fatLabel.backgroundColor = colorForLevel(level)
                    case .SaturatedFat:
                        saturatedFatLabel.backgroundColor = colorForLevel(level)
                    case .Sugar:
                        sugarLabel.backgroundColor = colorForLevel(level)
                    case .Salt:
                        saltLabel.backgroundColor = colorForLevel(level)
                    case .Undefined:
                        fatLabel.backgroundColor = UIColor.whiteColor()
                        saturatedFatLabel.backgroundColor = UIColor.whiteColor()
                        sugarLabel.backgroundColor = UIColor.whiteColor()
                        saltLabel.backgroundColor = UIColor.whiteColor()
                    }
                }
            }
        }
    }
    
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var saturatedFatLabel: UILabel!
    @IBOutlet weak var sugarLabel: UILabel!
    @IBOutlet weak var saltLabel: UILabel!
    
    
    private func colorForLevel(level: FoodProduct.NutritionLevelQuantity) -> UIColor {
        switch level {
        case .Low:
            return UIColor.greenColor()
        case .Moderate:
            return UIColor.orangeColor()
        case.High:
            return UIColor.redColor()
        default:
            return UIColor.whiteColor()
        }
    }
}