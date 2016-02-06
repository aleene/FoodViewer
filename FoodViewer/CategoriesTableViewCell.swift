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

    @IBOutlet weak var categoriesTagListView: TagListView! {
        didSet {
            categoriesTagListView.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            categoriesTagListView.alignment = .Center
        }
    }
    
    var product: FoodProduct? = nil {
        didSet {
            if let categories = product?.categories {
                categoriesTagListView.removeAllTags()
                for category in categories {
                    categoriesTagListView.addTag(category)
                }
            }
        }
    }
}
