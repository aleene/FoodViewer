//
//  AllergensTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 01/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import TagListView

class AllergensTableViewCell: UITableViewCell {

    @IBOutlet weak var allergensTagListView: TagListView! {
        didSet {
            allergensTagListView.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            allergensTagListView.alignment = .Center
        }
    }

    
    var product: FoodProduct? = nil {
        didSet {
            if let allergens = product?.allergens {
                allergensTagListView.removeAllTags()
                for allergen in allergens {
                    allergensTagListView.addTag(allergen)
                }
            }
        }
    }

}
