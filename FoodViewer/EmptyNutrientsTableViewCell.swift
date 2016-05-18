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
            tagListView.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            tagListView.alignment = .Center
            tagListView.cornerRadius = 10
        }
    }
    
    var availability: NutritionAvailability = .NotIndicated {
        didSet {
            tagListView.removeAllTags()
            tagListView.addTag(availability.description())
            switch availability {
            case .PerServing, .PerStandardUnit, .PerServingAndStandardUnit:
                tagListView.tagBackgroundColor = UIColor.greenColor()
            case .NotOnPackage:
                tagListView.tagBackgroundColor = UIColor.orangeColor()
            case .NotIndicated, .NotAvailable:
                tagListView.tagBackgroundColor = UIColor.redColor()
            }
        }
    }
}
