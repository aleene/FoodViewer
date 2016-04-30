//
//  AllergensFullTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 24/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class AllergensFullTableViewCell: UITableViewCell {

    struct Constants {
        static let NoTag = NSLocalizedString("no allergens detected", comment: "Text in a TagListView, when no allerges have been detected in the product ingredients.") 
    }

    @IBOutlet weak var allergensTagList: TagListView! {
        didSet {
            allergensTagList.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            allergensTagList.alignment = .Center
            allergensTagList.cornerRadius = 10
        }
    }
    
    var tagList: [String]? = nil {
        didSet {
            if let list = tagList {
                allergensTagList.removeAllTags()
                if !list.isEmpty {
                    for listItem in list {
                        allergensTagList.addTag(listItem)
                    }
                    allergensTagList.tagBackgroundColor = UIColor.greenColor()
                } else {
                    allergensTagList.addTag(Constants.NoTag)
                    allergensTagList.tagBackgroundColor = UIColor.orangeColor()
                }
            } else {
                allergensTagList.removeAllTags()
                allergensTagList.addTag(Constants.NoTag)
                allergensTagList.tagBackgroundColor = UIColor.orangeColor()
            }
        }
    }

}
