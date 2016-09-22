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
                    case .fat:
                        fatLabel.backgroundColor = colorForLevel(level)
                    case .saturatedFat:
                        saturatedFatLabel.backgroundColor = colorForLevel(level)
                    case .sugar:
                        sugarLabel.backgroundColor = colorForLevel(level)
                    case .salt:
                        saltLabel.backgroundColor = colorForLevel(level)
                    case .undefined:
                        fatLabel.backgroundColor = UIColor.white
                        saturatedFatLabel.backgroundColor = UIColor.white
                        sugarLabel.backgroundColor = UIColor.white
                        saltLabel.backgroundColor = UIColor.white
                    }
                }
            }
            if let score = product?.nutritionGrade {
                switch  score {
                case .a:
                    self.backgroundColor = UIColor.green
                case .b:
                    self.backgroundColor = UIColor.yellow
                case .c:
                    self.backgroundColor = UIColor.orange
                case .d:
                    self.backgroundColor = UIColor.magenta
                case .e:
                    self.backgroundColor = UIColor.red
                default:
                    self.backgroundColor = nil
                }
            }
        }
    }
    
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var saturatedFatLabel: UILabel!
    @IBOutlet weak var sugarLabel: UILabel!
    @IBOutlet weak var saltLabel: UILabel!
    
    
    fileprivate func colorForLevel(_ level: NutritionLevelQuantity) -> UIColor {
        switch level {
        case .low:
            return UIColor.green
        case .moderate:
            return UIColor.orange
        case.high:
            return UIColor.red
        default:
            return UIColor.white
        }
    }
}
