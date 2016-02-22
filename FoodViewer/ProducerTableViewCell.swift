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

    private struct Constants {
        static let NoInformation = "No producer info available"
    }

    @IBOutlet weak var producerTagListView: TagListView! {
        didSet {
            producerTagListView.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            producerTagListView.alignment = .Center
            producerTagListView.cornerRadius = 10
        }
    }
    
    var tagList: [String]? = nil {
        didSet {
            producerTagListView.removeAllTags()
            if let list = tagList {
                producerTagListView.tagBackgroundColor = UIColor.greenColor()
                for listItem in list {
                    producerTagListView.addTag(listItem)
                }
            } else {
                producerTagListView.tagBackgroundColor = UIColor.orangeColor()
                producerTagListView.addTag(Constants.NoInformation)
            }
        }
    }
}
