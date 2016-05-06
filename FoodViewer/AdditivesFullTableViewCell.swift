//
//  AdditivesFullTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 24/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class AdditivesFullTableViewCell: UITableViewCell {

    struct Constants {
        static let NoTag = NSLocalizedString("no additives detected", comment: "Text in a TagListView, when no additives (E-numbers) have been detected in the product ingredients.")
    }

    @IBOutlet weak var additivesTagListView: TagListView! {
        didSet {
            additivesTagListView.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            additivesTagListView.alignment = .Center
            additivesTagListView.cornerRadius = 10
        }
    }
    
    var tagList: [String]? = nil {
        didSet {
            if let list = tagList {
                additivesTagListView.removeAllTags()
                if !list.isEmpty {
                    for listItem in list {
                        additivesTagListView.tagBackgroundColor = UIColor.greenColor()
                        if listItem.contains(":") {
                            let tagView = additivesTagListView.addTag(listItem)
                            tagView.tagBackgroundColor = UIColor.blueColor()
                        } else {
                            additivesTagListView.addTag(listItem)
                        }
                    }
                } else {
                    additivesTagListView.addTag(Constants.NoTag)
                    additivesTagListView.tagBackgroundColor = UIColor.orangeColor()
                }
            } else {
                additivesTagListView.removeAllTags()
                additivesTagListView.addTag(Constants.NoTag)
                additivesTagListView.tagBackgroundColor = UIColor.orangeColor()
            }
        }
    }
}
