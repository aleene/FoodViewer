//
//  AddressTagListTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 10/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class AddressTagListTableViewCell: UITableViewCell {

    
    struct Constants {
        static let NoTag = NSLocalizedString("no producercode available", comment: "Text for an entry in a taglist, when no producer code is available. This is also indicated in a separate colour.")
    }
    
    @IBOutlet weak var tagListView: TagListView! {
        didSet {
            tagListView.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            tagListView.alignment = .Center
            tagListView.cornerRadius = 10
        }
    }
    
    var tagList: [Address]? = nil {
        didSet {
            if let list = tagList {
                tagListView.removeAllTags()
                if !list.isEmpty {
                    for listItem in list {
                        tagListView.addTag(listItem.raw)
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
    
}