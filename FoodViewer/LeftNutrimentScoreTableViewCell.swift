//
//  LeftNutrimentScoreTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 04/05/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

class LeftNutrimentScoreTableViewCell: UITableViewCell {
    
    var nutrimentScore : NutritionalScore.NutrimentScore? = nil {
        didSet {
            setup()
        }
    }
    
    var title: String? = nil {
        didSet {
            setup()
        }
    }
    
    var numBars: Int = 1 {
        didSet {
            setup()
        }
    }
    
    var maxLimit: Int = 10 {
        didSet {
            setup()
        }
    }

    var dangerThreshold: Int = 1 {
        didSet {
            setup()
        }
    }
    
    var warnThreshold: Int = 1 {
        didSet {
            setup()
        }
    }
    
    private func setup() {
        guard let validNutrimentScore = nutrimentScore else { return }
        nutrimentLabel.text = title
        nutrimentScoreBarGaugeView.value = Float(validNutrimentScore.points)
        nutrimentValue.text = "\(validNutrimentScore.points)"
        nutrimentScoreBarGaugeView?.numBars = numBars
        nutrimentScoreBarGaugeView?.maxLimit = Float(numBars)
        nutrimentScoreBarGaugeView?.dangerThreshold = Float(numBars)
        nutrimentScoreBarGaugeView.warnThreshold = Float(numBars)
        nutrimentScoreBarGaugeView?.reverse = false
        nutrimentScoreBarGaugeView?.normalBarColor = .red
    }
    
    @IBOutlet weak var nutrimentValue: UILabel!
        
    @IBOutlet weak var nutrimentScoreBarGaugeView: BarGaugeView! {
        didSet {
            nutrimentScoreBarGaugeView?.litEffect = false
        }
    }
        
    @IBOutlet weak var nutrimentLabel: UILabel!
        
}
