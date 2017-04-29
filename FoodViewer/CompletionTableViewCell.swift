//
//  CompletionTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 12/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class CompletionTableViewCell: UITableViewCell {

    fileprivate struct Constants {
        static let CompletePostText = NSLocalizedString("Data is %@ complete", comment: "Text to indicate how much the product data is filled in (available).")
    }
    var product: FoodProduct? = nil {
        didSet {
            if let productState = product?.state {
                completionBarGaugeView.maxLimit = 100.0
                completionBarGaugeView.litEffect = false
                completionBarGaugeView.normalBarColor = .red
                completionBarGaugeView.warningBarColor = .orange
                completionBarGaugeView.dangerBarColor = .green
                completionBarGaugeView.warnThreshold = 0.70 * completionBarGaugeView.maxLimit
                completionBarGaugeView.dangerThreshold = 0.90 * completionBarGaugeView.maxLimit
                completionBarGaugeView.outerBorderLineWidth = 0.0
                completionBarGaugeView.outerBorderInsetWidth = 0.0
                
                completionBarGaugeView.value = Float(productState.completionPercentage())
                //let formatter = NumberFormatter()
                //formatter.numberStyle = .percent
                //formatter.maximumFractionDigits = 0
                //let val = NSNumber.init(value:Double(productState.completionPercentage()) / 100.0)
                //if let valString = formatter.string(from: val) {
                //    completionLabel?.text = String(format:Constants.CompletePostText, valString)
                //}
            }
        }
    }

    @IBOutlet weak var completionBarGaugeView: BarGaugeView!

    @IBOutlet weak var completionLabel: UILabel!
}
