//
//  BeingLoadedTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 17/04/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//
/*
import UIKit

class BeingLoadedTableViewCell: UITableViewCell {
    
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
}

extension BeingLoadedTableViewCell: TagListViewDataSource {

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
}
 */
