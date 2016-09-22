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
            allergensTagList.textFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            allergensTagList.alignment = .center
            allergensTagList.cornerRadius = 10
        }
    }
    
    var tagList: [String]? = nil {
        didSet {
            if let list = tagList {
                allergensTagList.removeAllTags()
                if !list.isEmpty {
                    for listItem in list {
                        allergensTagList.tagBackgroundColor = UIColor.green
                        if listItem.contains(":") {
                            let tagView = allergensTagList.addTag(listItem)
                            tagView.tagBackgroundColor = UIColor.blue
                        } else {
                            allergensTagList.addTag(listItem)
                        }
                    }
                } else {
                    allergensTagList.addTag(Constants.NoTag)
                    allergensTagList.tagBackgroundColor = UIColor.orange
                }
            } else {
                allergensTagList.removeAllTags()
                allergensTagList.addTag(Constants.NoTag)
                allergensTagList.tagBackgroundColor = UIColor.orange
            }
        }
    }

}
