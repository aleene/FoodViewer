//
//  TagListViewTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 14/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class TagListViewTableViewCell: UITableViewCell {

    
    @IBOutlet weak var tagListView: TagListView! {
        didSet {
            tagListView.textFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            tagListView.alignment = .center
            tagListView.normalColorScheme = ColorSchemes.normal
            tagListView.removableColorScheme = ColorSchemes.removable
            tagListView.cornerRadius = 10
            tagListView.removeButtonIsEnabled = true
            tagListView.clearButtonIsEnabled = true
            
            tagListView.datasource = datasource
            tagListView.delegate = delegate
            tagListView.allowsRemoval = editMode
            tagListView.allowsCreation = editMode
            tagListView.tag = tag
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
    
    var editMode: Bool = false {
        didSet {
            if editMode != oldValue {
                tagListView?.allowsRemoval = editMode
                tagListView?.allowsCreation = editMode
            }
        }
    }
    
    override var tag: Int {
        didSet {
            tagListView?.tag = tag
        }
    }
    
}
