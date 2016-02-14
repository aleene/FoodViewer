//
//  PurchaseLocationTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 14/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import TagListView

class PurchaseLocationTableViewCell: UITableViewCell {

var tagList: [String]? = nil {
    didSet {
        if let list = tagList {
            locationTagListView.removeAllTags()
            for listItem in list {
                locationTagListView.addTag(listItem)
            }
        }
    }
}



    @IBOutlet weak var locationTagListView: TagListView! {
        didSet {
            locationTagListView.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            locationTagListView.alignment = .Center
            locationTagListView.tagBackgroundColor = UIColor.greenColor()
            locationTagListView.cornerRadius = 10
        }
    }
}
