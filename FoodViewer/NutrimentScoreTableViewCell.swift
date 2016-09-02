//
//  NutrimentScoreTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 08/06/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class NutrimentScoreTableViewCell: UITableViewCell {
    
    var nutrimentScore = ("", 0, 1, 0) {
        didSet {
            nutrimentLabel.text = nutrimentScore.0
            let formatter = NSNumberFormatter()
            formatter.locale = NSLocale.currentLocale()
            formatter.numberStyle = .NoStyle
            formatter.maximumIntegerDigits = 2
            valueLabel.text = formatter.stringFromNumber(nutrimentScore.1)
            if nutrimentScore.2 == 10 {
                switch nutrimentScore.1 {
                case 0,1,2:
                    nutrimentLabel.superview?.backgroundColor = UIColor.greenColor()
                case 3,4:
                    nutrimentLabel.superview?.backgroundColor = UIColor.yellowColor()
                case 5,6:
                    nutrimentLabel.superview?.backgroundColor = UIColor.orangeColor()
                case 7,8:
                    nutrimentLabel.superview?.backgroundColor = UIColor.magentaColor()
                case 9,10:
                    nutrimentLabel.superview?.backgroundColor = UIColor.redColor()
                default:
                    nutrimentLabel.superview?.backgroundColor = UIColor.whiteColor()
                }
            } else {
                switch nutrimentScore.1 {
                case 0,1:
                    nutrimentLabel.superview?.backgroundColor = UIColor.greenColor()
                case 2:
                    nutrimentLabel.superview?.backgroundColor = UIColor.yellowColor()
                case 3:
                    nutrimentLabel.superview?.backgroundColor = UIColor.orangeColor()
                case 4:
                    nutrimentLabel.superview?.backgroundColor = UIColor.magentaColor()
                case 5:
                    nutrimentLabel.superview?.backgroundColor = UIColor.redColor()
                default:
                    nutrimentLabel.superview?.backgroundColor = UIColor.whiteColor()
                }
            }
        }
    }

    @IBOutlet weak var nutrimentLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
}
