//
//  CategoriesTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 01/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import TagListView

class CategoriesTableViewCell: UITableViewCell {

    private struct Constants {
        static let NoInformation = NSLocalizedString("No categories specified.", comment: "Text to indicate that No categories have been specified in the product data.") 
        static let CategoryText = NSLocalizedString("Assigned to %@ categories.", comment: "Text to indicate the number of categories the product belongs to.")
    }

    @IBOutlet weak var categorySummaryLabel: UILabel!
    
    var product: FoodProduct? = nil {
        didSet {
            if let categories = product?.categories {
                if !categories.isEmpty {
                    let formatter = NSNumberFormatter()
                    formatter.numberStyle = .DecimalStyle
                    
                    categorySummaryLabel.text = String(format: Constants.CategoryText, formatter.stringFromNumber(categories.count)!)
                } else {
                    categorySummaryLabel.text = Constants.NoInformation

                }
                
            } else {
                categorySummaryLabel.text = Constants.NoInformation
            }
        }
    }
}
