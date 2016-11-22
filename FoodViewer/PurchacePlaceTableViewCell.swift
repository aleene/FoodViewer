//
//  PurchacePlaceTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 21/11/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class PurchacePlaceTableViewCell: UITableViewCell {

    struct Constants {
        static let NoTag = NSLocalizedString("no location specified", comment: "Text in a TagListView, when no purchase location are available in the product data.")
    }

    var editMode: Bool = false {
        didSet {
            if editMode != oldValue {
                setupInterface()
            }
        }
    }
    
    
    var tagList: [String]? = nil {
        didSet {
            setupInterface()
            if let list = tagList {
                tagListView.removeAllTags()
                if !list.isEmpty {
                    for listItem in list {
                        tagListView.addTag(listItem)
                    }
                    tagListView.tagBackgroundColor = UIColor.green
                } else {
                    tagListView.addTag(Constants.NoTag)
                    tagListView.tagBackgroundColor = UIColor.orange
                }
            } else {
                tagListView.removeAllTags()
                tagListView.addTag(Constants.NoTag)
                tagListView.tagBackgroundColor = UIColor.orange
            }
        }
    }
    
    private func setupInterface() {
        if favoriteButton != nil {
            favoriteButton.isHidden = !editMode
        }
    }
    
    @IBOutlet weak var tagListView: TagListView! {
        didSet {
            tagListView.textFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            tagListView.alignment = .center
            tagListView.cornerRadius = 10
        }
    }

    @IBOutlet weak var favoriteButton: UIButton!
    
}
