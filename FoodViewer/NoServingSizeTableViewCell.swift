//
//  NoServingSizeTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 12/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class NoServingSizeTableViewCell: UITableViewCell, TagListViewDataSource {

    struct Constants {
        static let NoTag = NSLocalizedString("no serving size available", comment: "Text for an entry in a taglist, when no serving size is available. This is also indicated in a separate colour.")
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
    
    
    /// Is it allowed to edit a Tag object at a given index?
    public func tagListView(_ tagListView: TagListView, canEditTagAt index: Int) -> Bool {
        return false
    }
    
    /// Is it allowed to move a Tag object at a given index?
    public func tagListView(_ tagListView: TagListView, canMoveTagAt index: Int) -> Bool {
        return false
    }
    /// The Tag object at the source index has been moved to a destination index.
    public func tagListView(_ tagListView: TagListView, moveTagAt sourceIndex: Int, to destinationIndex: Int) {
    }
    
    /// Called if the user wants to delete all tags
    public func didClear(_ tagListView: TagListView) {
    }
    
    /// Which text should be displayed when the TagListView is collapsed?
    public func tagListViewCollapsedText(_ tagListView: TagListView) -> String {
        return "Stub text"
    }
}
