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
        if let users = product?.contributors {
            return users.count
        }
        return 1
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        if let users = product?.contributors,
            let validName = users[index].name {
                return validName
        }
        // TODO:
        return "CommunityTableViewCell: No users"
    }

}
