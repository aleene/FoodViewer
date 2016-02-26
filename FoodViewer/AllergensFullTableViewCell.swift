//
//  AllergensFullTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 24/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import TagListView

class AllergensFullTableViewCell: UITableViewCell {

    @IBOutlet weak var allergensTagList: TagListView! {
        didSet {
            allergensTagList.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            allergensTagList.alignment = .Center
            allergensTagList.tagBackgroundColor = UIColor.greenColor()
            allergensTagList.cornerRadius = 10
        }
    }
    
    var tagList: [String]? = nil {
        didSet {
            if let list = tagList {
                allergensTagList.removeAllTags()
                for listItem in list {
                    allergensTagList.addTag(listItem)
                }
            }
        }
    }

}
