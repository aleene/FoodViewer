//
//  TagListViewTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 14/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class TagListViewTableViewCell: UITableViewCell {

    private struct Constants {
        static let Margin = CGFloat( 8.0 )
    }
    
    @IBOutlet weak var tagListView: TagListView! {
        didSet {
            tagListView.textFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            tagListView.alignment = .center
            tagListView.normalColorScheme = scheme
            tagListView.removableColorScheme = ColorSchemes.removable
            tagListView.cornerRadius = 10
            tagListView.removeButtonIsEnabled = true
            tagListView.clearButtonIsEnabled = true
            tagListView.frame.size.width = self.frame.size.width
            
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
    
    var width: CGFloat = CGFloat(320.0) {
        didSet {
            tagListView?.frame.size.width = width - Constants.Margin
            // print("Cell", tagListView.frame.size.width)
        }
    }
    
    var scheme = ColorSchemes.normal {
        didSet {
            tagListView?.normalColorScheme = scheme
        }
    }
    
    override var tag: Int {
        didSet {
            tagListView?.tag = tag
        }
    }
    
    func reloadData() {
        tagListView.reloadData(clearAll: true)
    }
    
}
