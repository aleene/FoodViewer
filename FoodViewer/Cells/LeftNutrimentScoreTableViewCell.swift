//
//  LeftNutrimentScoreTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 04/05/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

class LeftNutrimentScoreTableViewCell: UITableViewCell {
    
    private var nutrimentScore : NutrimentScore? = nil
    
    private var title: String? = nil
    
    private var numBars: Int = 1
    
    private var maxLimit: Int = 10

    private var dangerThreshold: Int = 1
    
    private var reverse: Bool = false

    private var warnThreshold: Int = 1
    
    private var normalBarColor: UIColor = .red

    private func setup() {
        guard let validNutrimentScore = nutrimentScore else { return }
        nutrimentLabel.text = title
        nutrimentScoreBarGaugeView.value = Float(validNutrimentScore.points)
        nutrimentValue.text = "\(validNutrimentScore.points)"
        nutrimentScoreBarGaugeView?.numBars = numBars
        nutrimentScoreBarGaugeView?.maxLimit = Float(numBars)
        nutrimentScoreBarGaugeView?.dangerThreshold = Float(numBars)
        nutrimentScoreBarGaugeView.warnThreshold = Float(numBars)
        nutrimentScoreBarGaugeView?.reverse = reverse
        nutrimentScoreBarGaugeView?.normalBarColor = normalBarColor
    }
    
    func setup(score:NutrimentScore?, numBars: Int, reverse:Bool, normalBarColor: UIColor, title:String?) {
        self.nutrimentScore = score
        self.numBars = numBars
        self.reverse = reverse
        self.normalBarColor = normalBarColor
        self.title = title
        setup()
    }
    
    @IBOutlet weak var nutrimentValue: UILabel!
        
    @IBOutlet weak var nutrimentScoreBarGaugeView: BarGaugeView! {
        didSet {
            nutrimentScoreBarGaugeView?.litEffect = false
        }
    }
        
    @IBOutlet weak var nutrimentLabel: UILabel!
        
}
