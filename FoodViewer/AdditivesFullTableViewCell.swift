//
//  AdditivesFullTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 24/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class AdditivesFullTableViewCell: UITableViewCell {

    @IBOutlet weak var additivesTagListView: TagListView! {
        didSet {
            additivesTagListView.textFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            additivesTagListView.alignment = .center
            additivesTagListView.normalColorScheme = ColorSchemes.normal
            additivesTagListView.removableColorScheme = ColorSchemes.removable
            additivesTagListView.cornerRadius = 10
            additivesTagListView.datasource = datasource
            additivesTagListView.delegate = delegate
        }
    }
    
    var datasource: TagListViewDataSource? = nil {
        didSet{
            additivesTagListView?.datasource = datasource
        }
    }
    
    var delegate: TagListViewDelegate? = nil {
        didSet{
            additivesTagListView?.delegate = delegate
        }
    }
    
    override var tag: Int {
        didSet {
            additivesTagListView.tag = tag
        }
    }
    
}
