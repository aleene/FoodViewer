//
//  NutrimentScoreTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 08/06/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class NutrimentScoreTableViewCell: UITableViewCell {
    
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
    
    var reverse: Bool = false {
        didSet {
            setup()
        }
    }
    
    var normalBarColor: UIColor = .red {
        didSet {
            setup()
        }
    }
    private func setup() {
        guard let validNutrimentScore = nutrimentScore else { return }
        nutrimentLabel.text = title
        nutrimentScoreBarGaugeView.value = Float(validNutrimentScore.points)
        if reverse {
            nutrimentValue.text = "\(-validNutrimentScore.points)"
        } else {
            nutrimentValue.text = "\(validNutrimentScore.points)"
        }
        nutrimentScoreBarGaugeView?.numBars = numBars
        nutrimentScoreBarGaugeView?.maxLimit = Float(numBars)
        nutrimentScoreBarGaugeView?.dangerThreshold = Float(numBars)
        nutrimentScoreBarGaugeView.warnThreshold = Float(numBars)
        nutrimentScoreBarGaugeView?.reverse = reverse
        nutrimentScoreBarGaugeView?.normalBarColor = normalBarColor
    }

    @IBOutlet weak var nutrimentValue: UILabel!
    
    @IBOutlet weak var nutrimentScoreBarGaugeView: BarGaugeView! {
        didSet {
            nutrimentScoreBarGaugeView.litEffect = false
        }
    }

    @IBOutlet weak var nutrimentLabel: UILabel!
    
}
