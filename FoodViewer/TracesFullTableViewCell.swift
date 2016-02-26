//
//  TracesFullTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 24/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import TagListView

class TracesFullTableViewCell: UITableViewCell {

    @IBOutlet weak var tracesTagList: TagListView! {
        didSet {
            tracesTagList.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            tracesTagList.alignment = .Center
            tracesTagList.tagBackgroundColor = UIColor.greenColor()
            tracesTagList.cornerRadius = 10
        }
    }
    
    var tagList: [String]? = nil {
        didSet {
            if let list = tagList {
                tracesTagList.removeAllTags()
                for listItem in list {
                    tracesTagList.addTag(listItem)
                }
            }
        }
    }


}
