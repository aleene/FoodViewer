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
        static let CompletePostText = NSLocalizedString("Data is %@ complete.", comment: "Text to indicate how much the product data is filled in (available).")
    }
    var product: FoodProduct? = nil {
        didSet {
            if let productState = product?.state {
                let formatter = NumberFormatter()
                formatter.numberStyle = .percent
                formatter.maximumFractionDigits = 0
                let val = NSNumber.init(value:Double(productState.completionPercentage()) / 100.0)
                if let valString = formatter.string(from: val) {
                    completionLabel?.text = String(format:Constants.CompletePostText, valString)
                }
            }
        }
    }

    @IBOutlet weak var completionLabel: UILabel!
}
