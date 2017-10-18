//
//  NoServingSizeTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 12/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class NoServingSizeTableViewCell: UITableViewCell {

    struct Constants {
        static let NoTag = TranslatableStrings.NoServingSizeAvailable
    }
    
    @IBOutlet weak var tagListView: TagListView! {
        didSet {
            tagListView.textFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            tagListView.alignment = .center
            tagListView.cornerRadius = 10
            tagListView.datasource = self
        }
    }
    
    var tagList: [String]? = nil {
        didSet {
            if let list = tagList {
                let newList = removeEmptyTags(list)
                if !newList.isEmpty {
                    tagListView.tagBackgroundColor = UIColor.green
                } else {
                    tagListView.tagBackgroundColor = UIColor.orange
                }
            } else {
                tagListView.tagBackgroundColor = UIColor.orange
            }
        }
    }
    
    func removeEmptyTags(_ list: [String]) -> [String] {
        var newList: [String] = []
        if !list.isEmpty {
            for listItem in list {
                if listItem.characters.count > 0 {
                    newList.append(listItem)
                }
            }
        }
        return newList
    }
}

extension NoServingSizeTableViewCell: TagListViewDataSource {

    // TagListView Datasource functions
    
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        if let list = tagList {
            let newList = removeEmptyTags(list)
            if !newList.isEmpty {
                return newList.count
            } else {
                return 1
            }
        } else {
            return 1
        }
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        if let list = tagList {
            let newList = removeEmptyTags(list)
            if !newList.isEmpty {
                return newList[index]
            } else {
                return Constants.NoTag
            }
        } else {
            return Constants.NoTag
        }
    }
    
}
