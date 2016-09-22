//
//  NutrimentScoreTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 08/06/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class NutrimentScoreTableViewCell: UITableViewCell {
    
    enum NutritionScoreType {
        case good
        case bad
    }

    var nutrimentScore: (String, Int, Int, Int, NutritionScoreType) = ("", 0, 1, 0, .bad) {
        didSet {
            nutrimentLabel.text = nutrimentScore.0
            let formatter = NumberFormatter()
            formatter.locale = Locale.current
            formatter.numberStyle = .none
            formatter.maximumIntegerDigits = 2
            valueLabel.text = formatter.string(from: NSNumber(integerLiteral: nutrimentScore.1))
            
            switch nutrimentScore.4 {
            case .bad:
                let score = nutrimentScore.2 == 10 ? nutrimentScore.1 / 2 : nutrimentScore.1
                switch score {
                case 1:
                    nutrimentLabel.superview?.backgroundColor = UIColor(red:1.00, green:0.80, blue:0.80, alpha:1.0)
                case 2:
                    nutrimentLabel.superview?.backgroundColor = UIColor(red:1.00, green:0.60, blue:0.60, alpha:1.0)
                case 3:
                    nutrimentLabel.superview?.backgroundColor = UIColor(red:1.00, green:0.40, blue:0.40, alpha:1.0)
                case 4:
                    nutrimentLabel.superview?.backgroundColor = UIColor(red:1.00, green:0.20, blue:0.20, alpha:1.0)
                case 5:
                    nutrimentLabel.superview?.backgroundColor = UIColor(red:1.00, green:0.00, blue:0.00, alpha:1.0)
                default:
                    nutrimentLabel.superview?.backgroundColor = UIColor.white
                }
            case .good:
                let score = nutrimentScore.2 == 10 ? nutrimentScore.1 / 2 : nutrimentScore.1
                switch score {
                case 1:
                    nutrimentLabel.superview?.backgroundColor = UIColor(red:0.80, green:1.00, blue:0.80, alpha:1.0)
                case 2:
                    nutrimentLabel.superview?.backgroundColor = UIColor(red:0.60, green:1.00, blue:0.60, alpha:1.0)
                case 3:
                    nutrimentLabel.superview?.backgroundColor = UIColor(red:0.40, green:1.00, blue:0.40, alpha:1.0)
                case 4:
                    nutrimentLabel.superview?.backgroundColor = UIColor(red:0.20, green:1.00, blue:0.20, alpha:1.0)
                case 5:
                    nutrimentLabel.superview?.backgroundColor = UIColor(red:0.00, green:1.00, blue:0.00, alpha:1.0)
                default:
                    nutrimentLabel.superview?.backgroundColor = UIColor.white
                }
            }
        }
    }

    @IBOutlet weak var nutrimentLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
}
