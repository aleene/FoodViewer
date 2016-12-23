//
//  CountriesTagListViewTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 07/03/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class CountriesTagListViewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var countriesTagListView: TagListView! {
        didSet {
            countriesTagListView.textFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            countriesTagListView.alignment = .center
            countriesTagListView.normalColorScheme = ColorSchemes.normal
            countriesTagListView.removableColorScheme = ColorSchemes.removable
            countriesTagListView.cornerRadius = 10
            countriesTagListView.datasource = datasource
            countriesTagListView.delegate = delegate
            countriesTagListView.isEditable = editMode
            countriesTagListView.tag = tag
        }
    }
    
    var editMode: Bool = false {
        didSet {
            countriesTagListView?.isEditable = editMode
        }
    }
    
    var datasource: TagListViewDataSource? = nil {
        didSet {
            countriesTagListView?.datasource = datasource
        }
    }
    
    var delegate: TagListViewDelegate? = nil {
        didSet {
            countriesTagListView?.delegate = delegate
        }
    }
    
    override var tag: Int {
        didSet {
            countriesTagListView?.tag = tag
        }
    }
    
}
