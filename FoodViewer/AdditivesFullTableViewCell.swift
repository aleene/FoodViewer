//
//  AdditivesFullTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 24/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import TagListView

class AdditivesFullTableViewCell: UITableViewCell {

    @IBOutlet weak var additivesTagListView: TagListView! {
        didSet {
            additivesTagListView.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            additivesTagListView.alignment = .Center
            additivesTagListView.tagBackgroundColor = UIColor.greenColor()
            additivesTagListView.cornerRadius = 10
        }
    }
    
    var tagList: [String]? = nil {
        didSet {
            if let list = tagList {
                additivesTagListView.removeAllTags()
                for listItem in list {
                    additivesTagListView.addTag(listItem)
                }
            }
        }
    }

}
