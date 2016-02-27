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
        static let NoInformation = "No categories specified"
        static let PreText = "Assigned to "
        static let PostText = " categories."
    }

    @IBOutlet weak var categorySummaryLabel: UILabel!
    
    var product: FoodProduct? = nil {
        didSet {
            if let categories = product?.categories {
                if !categories.isEmpty {
                    categorySummaryLabel.text = Constants.PreText + "\(categories.count)" + Constants.PostText
                } else {
                    categorySummaryLabel.text = Constants.NoInformation

                }
                
            } else {
                categorySummaryLabel.text = Constants.NoInformation
            }
        }
    }
}
