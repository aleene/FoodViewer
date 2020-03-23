//
//  NutrimentScoreTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 08/06/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class NutrimentScoreTableViewCell: UITableViewCell {
    
    private var nutrimentScore : NutrimentScore? = nil
    
    private var title: String? = nil
    
    private var numBars: Int = 1
    
    private var maxLimit: Int = 10
    
    private var dangerThreshold: Int = 1
    
    private var warnThreshold: Int = 1
    
    private var reverse: Bool = false
    
    private var normalBarColor: UIColor = .red
    
    private func setup() {
        guard let validNutrimentScore = nutrimentScore else { return }
        nutrimentLabel?.text = title
        if reverse {
            nutrimentValue.text = "\(-validNutrimentScore.points)"
        } else {
            nutrimentValue.text = "\(validNutrimentScore.points)"
        }
        nutrimentScoreBarGaugeView?.numBars = numBars
        nutrimentScoreBarGaugeView?.maxLimit = Float(numBars)
        nutrimentScoreBarGaugeView?.dangerThreshold = Float(numBars)
        nutrimentScoreBarGaugeView?.warnThreshold = Float(numBars)
        nutrimentScoreBarGaugeView?.reverse = reverse
        nutrimentScoreBarGaugeView?.normalBarColor = normalBarColor
        nutrimentScoreBarGaugeView?.value = Float(validNutrimentScore.points)
    }
    
    func setup(score:NutrimentScore?, numBars: Int, reverse:Bool, normalBarColor: UIColor, title:String?) {
        self.nutrimentScore = score
        self.numBars = numBars
        self.reverse = reverse
        self.normalBarColor = normalBarColor
        self.title = title
        setup()
    }

    @IBOutlet weak var nutrimentValue: UILabel! {
        didSet {
            if #available(iOS 13.0, *) {
                nutrimentValue.textColor = .label
            } else {
                nutrimentValue.textColor = .black
            }
        }
    }
    
    @IBOutlet weak var nutrimentScoreBarGaugeView: BarGaugeView! {
        didSet {
            nutrimentScoreBarGaugeView.litEffect = false
        }
    }

    @IBOutlet weak var nutrimentLabel: UILabel! {
           didSet {
               if #available(iOS 13.0, *) {
                   nutrimentLabel.textColor = .label
               } else {
                   nutrimentLabel.textColor = .black
               }
           }
       }
    
}
