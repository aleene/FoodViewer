//
//  NoImageTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 12/04/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class NoImageTableViewCell: UITableViewCell {

    
    @IBOutlet weak var tagListView: TagListView! {
        didSet {
            tagListView.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            tagListView.alignment = .Center
            tagListView.cornerRadius = 10
        }
    }
    
    var imageFetchStatus: ImageFetchResult = .NoData {
        didSet {
            tagListView.removeAllTags()
            switch imageFetchStatus {
            case .Success:
                tagListView.tagBackgroundColor = UIColor.greenColor()
            case .NoImageAvailable, .NoData, .LoadingFailed:
                tagListView.tagBackgroundColor = UIColor.redColor()
            case .Loading:
                tagListView.tagBackgroundColor = UIColor.orangeColor()
            }
            tagListView.addTag(imageFetchStatus.description())
        }
    }

}
