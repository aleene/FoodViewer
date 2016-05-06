//
//  TracesFullTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 24/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class TracesFullTableViewCell: UITableViewCell {

    struct Constants {
        static let NoTag = NSLocalizedString("no traces specified", comment: "Text in a TagListView, when no traces have been specified in the product data.")
    }

    @IBOutlet weak var tracesTagList: TagListView! {
        didSet {
            tracesTagList.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            tracesTagList.alignment = .Center
            tracesTagList.cornerRadius = 10
        }
    }
    
    var tagList: [String]? = nil {
        didSet {
            if let list = tagList {
                tracesTagList.removeAllTags()
                if !list.isEmpty {
                    for listItem in list {
                        tracesTagList.tagBackgroundColor = UIColor.greenColor()
                        if listItem.contains(":") {
                            let tagView = tracesTagList.addTag(listItem)
                            tagView.tagBackgroundColor = UIColor.blueColor()
                        } else {
                            tracesTagList.addTag(listItem)
                        }
                    }
                } else {
                    tracesTagList.addTag(Constants.NoTag)
                    tracesTagList.tagBackgroundColor = UIColor.orangeColor()
                }
            } else {
                tracesTagList.removeAllTags()
                tracesTagList.addTag(Constants.NoTag)
                tracesTagList.tagBackgroundColor = UIColor.orangeColor()
            }
        }
    }

}
