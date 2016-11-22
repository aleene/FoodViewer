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
    
    var editMode = false {
        didSet {
            // if the editmode changes I should repaint the view
            if editMode != oldValue {
                setTags()
            }
        }
    }
    
    var tagList: [String]? = nil {
        didSet {
            setTags()
        }
    }

    private func setTags() {
        if let list = tagList {
            tagListView.removeAllTags()
            if !list.isEmpty {
                for (index, listItem) in list.enumerated() {
                    if editMode {
                        tagListView.insertTag(listItem + " X", at: index)
                    } else {
                        tagListView.addTag(listItem)
                    }
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
