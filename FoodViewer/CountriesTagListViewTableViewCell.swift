//
//  CountriesTagListViewTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 07/03/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class CountriesTagListViewTableViewCell: UITableViewCell, TagListViewDataSource {
    
    struct Constants {
        static let NoTag = NSLocalizedString("no countries specified", comment: "Text in a TagListView, when no countries are available in the product data.") 
    }
    
    @IBOutlet weak var countriesTagListView: TagListView! {
        didSet {
            countriesTagListView.textFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            countriesTagListView.alignment = .center
            countriesTagListView.cornerRadius = 10
            countriesTagListView.datasource = self
        }
    }
    
    var tagList: [Address]? = nil {
        didSet {
            if let list = tagList {
                if !list.isEmpty {
                    countriesTagListView.tagBackgroundColor = UIColor.green
                    return
                }
            }
            countriesTagListView.tagBackgroundColor = UIColor.orange
        }
    }
    
    // TagListView Datasource functions
    
    func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        if let list = tagList {
            if !list.isEmpty {
                return list.count
            }
        }
        return 1
    }
    
    func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        if let list = tagList {
            if !list.isEmpty {
                return list[index].country
            }
        }
        return Constants.NoTag
    }

    
}
