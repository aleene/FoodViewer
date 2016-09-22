//
//  EmptyNutrientsTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 06/03/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class EmptyNutrientsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tagListView: TagListView! {
        didSet {
            tagListView.textFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            tagListView.alignment = .center
            tagListView.cornerRadius = 10
        }
    }
    
    var availability: NutritionAvailability = .notIndicated {
        didSet {
            tagListView.removeAllTags()
            tagListView.addTag(availability.description())
            switch availability {
            case .perServing, .perStandardUnit, .perServingAndStandardUnit:
                tagListView.tagBackgroundColor = UIColor.green
            case .notOnPackage:
                tagListView.tagBackgroundColor = UIColor.orange
            case .notIndicated, .notAvailable:
                tagListView.tagBackgroundColor = UIColor.red
            }
        }
    }
}
