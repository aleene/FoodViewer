//
//  CompletionTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 12/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class CompletionTableViewCell: UITableViewCell {

    var product: FoodProduct? = nil {
        didSet {
            if let productState = product?.state {                
                completionBarGaugeView.value = Float(productState.completionPercentage())
                if productState.completionPercentage() <= 60 {
                    completionBarGaugeView.normalBarColor = .red
                } else if productState.completionPercentage() <= 80 {
                    completionBarGaugeView.normalBarColor = .orange
                } else if productState.completionPercentage() <= 90 {
                    completionBarGaugeView.normalBarColor = .yellow
                } else {
                    completionBarGaugeView.normalBarColor = .green
                }
            }
        }
    }

    @IBOutlet weak var completionBarGaugeView: BarGaugeView! {
        didSet {
            completionBarGaugeView.maxLimit = 100.0
            completionBarGaugeView.litEffect = false
            completionBarGaugeView.normalBarColor = .red
            completionBarGaugeView.warnThreshold = completionBarGaugeView.maxLimit
            completionBarGaugeView.dangerThreshold = completionBarGaugeView.maxLimit
            completionBarGaugeView.outerBorderLineWidth = 0.0
            completionBarGaugeView.outerBorderInsetWidth = 0.0
        }
    }

    @IBOutlet weak var completionLabel: UILabel! {
        didSet {
            completionLabel.text = TranslatableStrings.Completion
        }
    }
}
