//
//  NoServingSizeTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 12/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class NoServingSizeTableViewCell: UITableViewCell {

    struct Constants {
        static let NoTag = NSLocalizedString("no serving size available", comment: "Text for an entry in a taglist, when no serving size is available. This is also indicated in a separate colour.")
    }
    
    @IBOutlet weak var tagListView: TagListView! {
        didSet {
            tagListView.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            tagListView.alignment = .Center
            tagListView.cornerRadius = 10
        }
    }
    
    var tagList: [String]? = nil {
        didSet {
            if let list = tagList {
                tagListView.removeAllTags()
                let newList = removeEmptyTags(list)
                if !newList.isEmpty {
                    for listItem in newList {
                        tagListView.addTag(listItem)
                    }
                    tagListView.tagBackgroundColor = UIColor.greenColor()
                } else {
                    tagListView.addTag(Constants.NoTag)
                    tagListView.tagBackgroundColor = UIColor.orangeColor()
                }
            } else {
                tagListView.removeAllTags()
                tagListView.addTag(Constants.NoTag)
                tagListView.tagBackgroundColor = UIColor.orangeColor()
            }
        }
    }
    
    func removeEmptyTags(list: [String]) -> [String] {
        var newList: [String] = []
        if !list.isEmpty {
            for listItem in list {
                if listItem.characters.count > 0 {
                    newList.append(listItem)
                }
            }
        }
        return newList
    }
}