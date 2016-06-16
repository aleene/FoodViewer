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
            scoreProgressView.progress = (Float(nutrimentScore.1) + Float(nutrimentScore.3)) / Float(nutrimentScore.2)
            let formatter = NSNumberFormatter()
            formatter.locale = NSLocale.currentLocale()
            formatter.numberStyle = .NoStyle
            formatter.maximumIntegerDigits = 2
            valueLabel.text = formatter.stringFromNumber(nutrimentScore.1)
        }
    }

    @IBOutlet weak var nutrimentLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var scoreProgressView: UIProgressView!
}
