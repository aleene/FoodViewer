//
//  EmptyNutrientsTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 06/03/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class EmptyNutrientsTableViewCell: UITableViewCell, TagListViewDataSource {
    
    @IBOutlet weak var tagListView: TagListView! {
        didSet {
            tagListView.textFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            tagListView.alignment = .center
            tagListView.cornerRadius = 10
            tagListView.datasource = self
        }
    }
    
    var availability: NutritionAvailability = .notIndicated {
        didSet {
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
    
    // TagListView Datasource functions
    
    func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        return 1
    }
    
    func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        return availability.description()
    }

}
