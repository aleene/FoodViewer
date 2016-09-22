//
//  ColourCodedNutritionalScoreTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 15/06/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class ColourCodedNutritionalScoreTableViewCell: UITableViewCell {
    
    var score: Int? = nil {
        didSet {
            resetLabels()
            if let validScore = score {
                if validScore < 0 {
                    firstMiddleLabel.text = "\(validScore)"
                } else if validScore < 3 {
                    secondMiddleLabel.text = "\(validScore)"
                } else if validScore < 11 {
                    thirdMiddleLabel.text = "\(validScore)"
                } else if validScore < 19 {
                    fourthMiddleLabel.text = "\(validScore)"
                } else {
                    fifthMiddleLabel.text = "\(validScore)"
                }
            }
        }
    }
    
    fileprivate func resetLabels() {
        firstMiddleLabel.text = ""
        secondMiddleLabel.text = ""
        thirdMiddleLabel.text = ""
        fourthMiddleLabel.text = ""
        fifthMiddleLabel.text = ""
    }
    
    // Green labels
    @IBOutlet weak var firstLeftLabel: UILabel!
    @IBOutlet weak var firstMiddleLabel: UILabel!
    @IBOutlet weak var firstRightLabel: UILabel!
    
    // Yellow labels
    @IBOutlet weak var secondLeftLabel: UILabel!
    @IBOutlet weak var secondMiddleLabel: UILabel!
    @IBOutlet weak var secondRightLabel: UILabel!
    
    // Orange Labels
    @IBOutlet weak var thirdLeftLabel: UILabel!
    @IBOutlet weak var thirdMiddleLabel: UILabel!
    @IBOutlet weak var thirdRightLabel: UILabel!
    
    // Pink labels
    @IBOutlet weak var fourthLeftLabel: UILabel!
    @IBOutlet weak var fourthMiddleLabel: UILabel!
    @IBOutlet weak var fourthRightLabel: UILabel!
    
    // Red labels
    @IBOutlet weak var fifthLeftLabel: UILabel!
    @IBOutlet weak var fifthMiddleLabel: UILabel!
    @IBOutlet weak var fifthRightLabel: UILabel!
}
