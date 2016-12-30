//
//  CommunityTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 12/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class CommunityTableViewCell: UITableViewCell {

    var product: FoodProduct? = nil
    
    @IBOutlet weak var communityTagListView: TagListView! {
        didSet {
            communityTagListView.textFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            communityTagListView.alignment = .center
            communityTagListView.tagBackgroundColor = UIColor.green
            communityTagListView.cornerRadius = 10
            communityTagListView.datasource = self
        }
    }

}

extension CommunityTableViewCell: TagListViewDataSource {
    
    // MARK: - TagListView Datasource functions
    
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        if let users = product?.productContributors.contributors {
            return users.count
        }
        return 1
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        if let users = product?.productContributors.contributors {
            return users[index].name
        }
        // TODO:
        return "No users"
    }

    /*
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
    */
}
