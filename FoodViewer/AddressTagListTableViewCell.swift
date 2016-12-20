//
//  AddressTagListTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 10/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class AddressTagListTableViewCell: UITableViewCell, TagListViewDataSource {

    
    struct Constants {
        static let NoTag = NSLocalizedString("no producercode available", comment: "Text for an entry in a taglist, when no producer code is available. This is also indicated in a separate colour.")
    }
    
    @IBOutlet weak var tagListView: TagListView! {
        didSet {
            tagListView.textFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            tagListView.alignment = .center
            tagListView.cornerRadius = 10
            tagListView.datasource = self
        }
    }
    
    var tagList: [Address]? = nil {
        didSet {
            if let list = tagList {
                if !list.isEmpty {
                    tagListView.tagBackgroundColor = UIColor.green
                    return
                }
            }
            tagListView.tagBackgroundColor = UIColor.orange
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
                return list[index].raw
            }
        }
        return Constants.NoTag
    }
    
}
