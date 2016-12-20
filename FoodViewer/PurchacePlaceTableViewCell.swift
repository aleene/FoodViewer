//
//  PurchacePlaceTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 21/11/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class PurchacePlaceTableViewCell: UITableViewCell, TagListViewDataSource {

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
                if !list.isEmpty {
                    tagListView.tagBackgroundColor = UIColor.green
                    return
                }
            }
            tagListView.tagBackgroundColor = UIColor.orange
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
            tagListView.datasource = self
        }
    }

    @IBOutlet weak var favoriteButton: UIButton!
    
    
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
                return list[index]
            }
        }
        return Constants.NoTag
    }

}
