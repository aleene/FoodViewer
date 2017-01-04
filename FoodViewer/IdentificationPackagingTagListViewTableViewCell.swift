//
//  IdentificationPackagingTagListViewTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 16/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit


class IdentificationPackagingTagListViewTableViewCell: UITableViewCell {

    @IBOutlet weak var tagListView: TagListView! {
        didSet {
            tagListView.textFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            tagListView.alignment = .center
            tagListView.normalColorScheme = ColorSchemes.normal
            tagListView.removableColorScheme = ColorSchemes.removable
            tagListView.cornerRadius = 10
            tagListView.clearButtonIsEnabled = true
            tagListView.removeButtonIsEnabled = true
            
            tagListView.allowsRemoval = editMode
            tagListView.allowsCreation = editMode
            tagListView.datasource = datasource
            tagListView.delegate = delegate
            tagListView.tag = tag
        }
    }
    
    override var tag: Int {
        didSet {
            tagListView?.tag = tag
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
            if editMode != oldValue {
                tagListView?.allowsRemoval = editMode
                tagListView?.allowsCreation = editMode
            }
        }
    }

}
