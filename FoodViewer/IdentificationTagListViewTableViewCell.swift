//
//  IdentificationTagListViewTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 16/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class IdentificationTagListViewTableViewCell: UITableViewCell {

    @IBOutlet weak var tagListView: TagListView! {
        didSet {
            tagListView.textFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            // tagListView.alignment = .center
            tagListView.tagBackgroundColor = UIColor.green
            tagListView.cornerRadius = 10
            tagListView?.isEditable = editMode
            tagListView?.datasource = datasource
            tagListView?.delegate = delegate
        }
    }
    
    var datasource: TagListViewDataSource? = nil {
        didSet {
            tagListView?.datasource = datasource
        }
    }
    
    var delegate: TagListViewDelegate? = nil {
        didSet {
            tagListView?.delegate = delegate
        }
    }
    var editMode = false {
        didSet {
            tagListView?.isEditable = editMode
        }
    }
    
}
