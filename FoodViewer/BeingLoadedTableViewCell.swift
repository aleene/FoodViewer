//
//  BeingLoadedTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 17/04/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class BeingLoadedTableViewCell: UITableViewCell, TagListViewDataSource {
    
    @IBOutlet weak var beingLoadedTagList: TagListView! {
        didSet {
            beingLoadedTagList.textFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            beingLoadedTagList.alignment = .center
            beingLoadedTagList.cornerRadius = 10
            beingLoadedTagList.datasource = self
        }
    }
    
    var status: ProductFetchStatus? = nil {
        didSet {
            if let validStatus = status {
                switch validStatus {
                case .success:
                    beingLoadedTagList.tagBackgroundColor = UIColor.green
                case .loading:
                    beingLoadedTagList.tagBackgroundColor = UIColor.orange
                default:
                    beingLoadedTagList.tagBackgroundColor = UIColor.red

                }
            } else {
                beingLoadedTagList.tagBackgroundColor = UIColor.orange
            }
        }
    }

    // TagListView Datasource functions
    
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        return 1
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        if let validStatus = status {
            return validStatus.description()
        } else {
            return ProductFetchStatus.loading.description()
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
