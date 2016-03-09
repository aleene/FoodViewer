//
//  CategoriesExtendedTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 27/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import TagListView

class CategoriesExtendedTableViewCell: UITableViewCell {
    
    private struct Constants {
        static let NoInformation = NSLocalizedString("no categories specified", comment: "Text in a TagListView, when no categories are available in the product data.") 
    }
        
    @IBOutlet weak var listTagListView: TagListView! {
        didSet {
            listTagListView.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            listTagListView.alignment = .Center
            listTagListView.cornerRadius = 10
        }
    }
        
    var tagList: [[String:String]]? = nil {
        didSet {
            listTagListView.removeAllTags()
            if let list = tagList {
                if !list.isEmpty {
                    listTagListView.tagBackgroundColor = UIColor.greenColor()
                    for listItem in list {
                        for (_, listItemValue) in listItem {
                            listTagListView.addTag(listItemValue)
                        }
                    }
                } else {
                    listTagListView.tagBackgroundColor = UIColor.orangeColor()
                    listTagListView.addTag(Constants.NoInformation)
                }
            } else {
                listTagListView.tagBackgroundColor = UIColor.orangeColor()
                listTagListView.addTag(Constants.NoInformation)
            }
        }
    }

}
