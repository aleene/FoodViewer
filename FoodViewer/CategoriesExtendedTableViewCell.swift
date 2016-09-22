//
//  CategoriesExtendedTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 27/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class CategoriesExtendedTableViewCell: UITableViewCell {
    
    fileprivate struct Constants {
        static let NoInformation = NSLocalizedString("no categories specified", comment: "Text in a TagListView, when no categories are available in the product data.") 
    }
        
    @IBOutlet weak var listTagListView: TagListView! {
        didSet {
            listTagListView.textFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            listTagListView.alignment = .center
            listTagListView.cornerRadius = 10
        }
    }
        
    var tagList: [String]? = nil {
        didSet {
            listTagListView.removeAllTags()
            if let list = tagList {
                if !list.isEmpty {
                    listTagListView.tagBackgroundColor = UIColor.green
                    for listItem in list {
                        if listItem.contains(":") {
                            let tagView = listTagListView.addTag(listItem)
                            tagView.tagBackgroundColor = UIColor.blue
                        } else {
                            listTagListView.addTag(listItem)
                        }
                    }
                } else {
                    listTagListView.tagBackgroundColor = UIColor.orange
                    listTagListView.addTag(Constants.NoInformation)
                }
            } else {
                listTagListView.tagBackgroundColor = UIColor.orange
                listTagListView.addTag(Constants.NoInformation)
            }
        }
    }

}
