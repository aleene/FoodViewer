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
            beingLoadedTagList.textFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            beingLoadedTagList.alignment = .center
            beingLoadedTagList.cornerRadius = 10
        }
    }
    
    var status: ProductFetchStatus? = nil {
        didSet {
            if let validStatus = status {
                beingLoadedTagList.removeAllTags()
                beingLoadedTagList.addTag(validStatus.description())
                switch validStatus {
                case .success:
                    beingLoadedTagList.tagBackgroundColor = UIColor.green
                case .loading:
                    beingLoadedTagList.tagBackgroundColor = UIColor.orange
                default:
                    beingLoadedTagList.tagBackgroundColor = UIColor.red

                }
            } else {
                beingLoadedTagList.removeAllTags()
                beingLoadedTagList.addTag(ProductFetchStatus.loading.description())
                beingLoadedTagList.tagBackgroundColor = UIColor.orange
            }
        }
    }
    
}
