//
//  BeingLoadedTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 17/04/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class BeingLoadedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var beingLoadedTagList: TagListView! {
        didSet {
            beingLoadedTagList.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            beingLoadedTagList.alignment = .Center
            beingLoadedTagList.cornerRadius = 10
        }
    }
    
    var status: ProductFetchStatus? = nil {
        didSet {
            if let validStatus = status {
                beingLoadedTagList.removeAllTags()
                beingLoadedTagList.addTag(validStatus.description())
                switch validStatus {
                case .Success:
                    beingLoadedTagList.tagBackgroundColor = UIColor.greenColor()
                case .Loading:
                    beingLoadedTagList.tagBackgroundColor = UIColor.orangeColor()
                default:
                    beingLoadedTagList.tagBackgroundColor = UIColor.redColor()

                }
            } else {
                beingLoadedTagList.removeAllTags()
                beingLoadedTagList.addTag(ProductFetchStatus.Loading.description())
                beingLoadedTagList.tagBackgroundColor = UIColor.orangeColor()
            }
        }
    }
    
}
