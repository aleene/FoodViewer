//
//  CompletionTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 12/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class CompletionTableViewCell: UITableViewCell {

    private struct Constants {
        static let CompletePostText = NSLocalizedString("Data is %@ complete.", comment: "Text to indicate how much the product data is filled in (available).")
    }
    var product: FoodProduct? = nil {
        didSet {
            if let percentage = product?.state.completionPercentage() {
                let formatter = NSNumberFormatter()
                formatter.numberStyle = .PercentStyle
                formatter.maximumFractionDigits = 0
                completionLabel?.text = String(format:Constants.CompletePostText , formatter.stringFromNumber(percentage/100)!)
            }
        }
    }

    @IBOutlet weak var completionLabel: UILabel!
}
