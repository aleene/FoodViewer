//
//  ProducerTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 14/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import TagListView

class ProducerTableViewCell: UITableViewCell {

    @IBOutlet weak var producerTagListView: TagListView! {
        didSet {
            producerTagListView.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            producerTagListView.alignment = .Center
            producerTagListView.tagBackgroundColor = UIColor.greenColor()
            producerTagListView.cornerRadius = 10
        }
    }
    
    var tagList: [String]? = nil {
        didSet {
            if let list = tagList {
                producerTagListView.removeAllTags()
                for listItem in list {
                    producerTagListView.addTag(listItem)
                }
            }
        }
    }
}
