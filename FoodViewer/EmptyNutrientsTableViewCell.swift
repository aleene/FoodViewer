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

    var editMode: Bool = false {
        didSet {
            if editMode {
                tagListView.backgroundColor = UIColor.groupTableViewBackground
                tagListView.layer.cornerRadius = 5
                tagListView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
                tagListView.clipsToBounds = true
            } else {
                tagListView.layer.cornerRadius = 5
                tagListView.backgroundColor = UIColor.white
                tagListView.layer.borderColor = UIColor.white.cgColor
            }
        }
    }

}

extension EmptyNutrientsTableViewCell: TagListViewDataSource {

    // TagListView Datasource functions
    
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        return 1
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        return availability.description()
    }

}
