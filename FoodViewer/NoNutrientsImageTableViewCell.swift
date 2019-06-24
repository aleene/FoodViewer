//
//  NoNutrientsImageTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 13/04/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//


import UIKit

class NoNutrientsImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tagListView: TagListView! {
        didSet {
            tagListView.textFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
            tagListView.alignment = .center
            tagListView.cornerRadius = 10
            tagListView.datasource = datasource
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

    var editMode: Bool = false
    
    var width: CGFloat = CGFloat(320.0)
    
    var scheme = ColorSchemes.normal {
        didSet {
            tagListView?.normalColorScheme = scheme
        }
    }
    
    var languageCode: String? = nil
    
    override var tag: Int {
        didSet {
            tagListView?.tag = tag
        }
    }
    
    func reloadData() {
        tagListView.reloadData(clearAll: true)
    }
    
}

