//
//  EmptyNutrientsTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 06/03/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import TagListView

class EmptyNutrientsTableViewCell: UITableViewCell {

    
    struct Constants {
        static let NoTag = NSLocalizedString("No info available.", comment: "Text in a TagListView, when no information have been specified in the product data.")
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
