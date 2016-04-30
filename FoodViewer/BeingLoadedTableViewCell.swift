//
//  BeingLoadedTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 17/04/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class BeingLoadedTableViewCell: UITableViewCell {

    struct Constants {
        static let NoTag = NSLocalizedString("product being loaded", comment: "Text in a TagListView, when to indicate the product is being loaded from Internet.")
    }
    
    @IBOutlet weak var beingLoadedTagList: TagListView! {
        didSet {
            beingLoadedTagList.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            beingLoadedTagList.alignment = .Center
            beingLoadedTagList.cornerRadius = 10
        }
    }
    
    var tagList: [String]? = nil {
        didSet {
            if let list = tagList {
                beingLoadedTagList.removeAllTags()
                if !list.isEmpty {
                    for listItem in list {
                        beingLoadedTagList.addTag(listItem)
                    }
                    beingLoadedTagList.tagBackgroundColor = UIColor.greenColor()
                } else {
                    beingLoadedTagList.addTag(Constants.NoTag)
                    beingLoadedTagList.tagBackgroundColor = UIColor.orangeColor()
                }
            } else {
                beingLoadedTagList.removeAllTags()
                beingLoadedTagList.addTag(Constants.NoTag)
                beingLoadedTagList.tagBackgroundColor = UIColor.orangeColor()
            }
        }
    }
    
}
