//
//  CountriesTagListViewTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 07/03/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import TagListView

class CountriesTagListViewTableViewCell: UITableViewCell {
    
    struct Constants {
        static let NoTag = NSLocalizedString("no countries specified", comment: "Text in a TagListView, when no countries are available in the product data.") 
    }
    
    @IBOutlet weak var countriesTagListView: TagListView! {
        didSet {
            countriesTagListView.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            countriesTagListView.alignment = .Center
            countriesTagListView.cornerRadius = 10
        }
    }
    
    var tagList: [[String: String]]? = nil {
        didSet {
            if let list = tagList {
                countriesTagListView.removeAllTags()
                if !list.isEmpty {
                    for listItem in list {
                        for (_, listItemValue) in listItem {
                            countriesTagListView.addTag(listItemValue)
                        }
                    }
                    countriesTagListView.tagBackgroundColor = UIColor.greenColor()
                } else {
                    countriesTagListView.addTag(Constants.NoTag)
                    countriesTagListView.tagBackgroundColor = UIColor.orangeColor()
                }
            } else {
                countriesTagListView.removeAllTags()
                countriesTagListView.addTag(Constants.NoTag)
                countriesTagListView.tagBackgroundColor = UIColor.orangeColor()
            }
        }
    }
    
}