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
    
    private struct Constants {
        static let NoInformation = "No purchase location available"
    }
    

var tagList: [String]? = nil {
    didSet {
        locationTagListView.removeAllTags()
        if let list = tagList {
            locationTagListView.tagBackgroundColor = UIColor.greenColor()
            for listItem in list {
                locationTagListView.addTag(listItem)
            }
        } else {
            locationTagListView.tagBackgroundColor = UIColor.orangeColor()
            locationTagListView.addTag(Constants.NoInformation)
        }
    }
}



    @IBOutlet weak var locationTagListView: TagListView! {
        didSet {
            locationTagListView.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            locationTagListView.alignment = .Center
            locationTagListView.cornerRadius = 10
        }
    }
}
