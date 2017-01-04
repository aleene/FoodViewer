//
//  CategoriesExtendedTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 27/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class CategoriesExtendedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var listTagListView: TagListView! {
        didSet {
            listTagListView.textFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            listTagListView.alignment = .center
            listTagListView.cornerRadius = 10
            listTagListView.normalColorScheme = ColorSchemes.normal
            listTagListView.removableColorScheme = ColorSchemes.removable
            listTagListView.clearButtonIsEnabled = true
            listTagListView.removeButtonIsEnabled = true

            listTagListView.datasource = datasource
            listTagListView.delegate = delegate
            listTagListView.tag = tag
            listTagListView.allowsRemoval = editMode
            listTagListView.allowsCreation = editMode
        }
    }

    var datasource: TagListViewDataSource? = nil {
        didSet{
            listTagListView?.datasource = datasource
        }
    }
    
    var delegate: TagListViewDelegate? = nil {
        didSet{
            listTagListView?.delegate = delegate
        }
    }

    var editMode: Bool = false {
        didSet{
            if editMode != oldValue {
                listTagListView?.allowsRemoval = editMode
                listTagListView?.allowsCreation = editMode
            }
        }
    }

    override var tag: Int {
        didSet {
            listTagListView?.tag = tag
        }
    }
    
}
