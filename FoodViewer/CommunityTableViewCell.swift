//
//  CommunityTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 12/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class CommunityTableViewCell: UITableViewCell, TagListViewDataSource {

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

    // TagListView Datasource functions
    
    func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        if let users = product?.productContributors.contributors {
            return users.count
        }
        return 1
    }
    
    func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        if let users = product?.productContributors.contributors {
            return users[index].name
        }
        // TODO:
        return "No users"
    }

}
