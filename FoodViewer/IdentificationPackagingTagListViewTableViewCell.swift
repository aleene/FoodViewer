//
//  IdentificationPackagingTagListViewTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 16/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

import TagListView

class IdentificationPackagingTagListViewTableViewCell: UITableViewCell {

    @IBOutlet weak var tagListView: TagListView! {
        didSet {
            tagListView.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            tagListView.alignment = .Center
            tagListView.tagBackgroundColor = UIColor.greenColor()
            tagListView.cornerRadius = 10
        }
    }
    
    var tagList: [String]? = nil {
        didSet {
            if let list = tagList {
                tagListView.removeAllTags()
                for listItem in list {
                    tagListView.addTag(listItem)
                }
            }
        }
    }

}
