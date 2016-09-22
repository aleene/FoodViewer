//
//  IdentificationTagListViewTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 16/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class IdentificationTagListViewTableViewCell: UITableViewCell {

    fileprivate struct Constants {
        static let NoInformation = NSLocalizedString("no brands specified", comment: "Text for tag in a separate colour, when no brands information is available in the product data.")
    }

    @IBOutlet weak var tagListView: TagListView! {
        didSet {
            tagListView.textFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            tagListView.alignment = .center
            tagListView.tagBackgroundColor = UIColor.green
            tagListView.cornerRadius = 10
        }
    }
    
    var tagList: [String]? = nil {
        didSet {
            if let list = tagList {
                tagListView.removeAllTags()
                if !list.isEmpty {
                    for listItem in list {
                        tagListView.addTag(listItem)
                    }
                    tagListView.tagBackgroundColor = UIColor.green
                } else {
                    tagListView.addTag(Constants.NoInformation)
                    tagListView.tagBackgroundColor = UIColor.orange
                }
            } else {
                tagListView.removeAllTags()
                tagListView.addTag(Constants.NoInformation)
                tagListView.tagBackgroundColor = UIColor.orange
            }
        }
    }

}
