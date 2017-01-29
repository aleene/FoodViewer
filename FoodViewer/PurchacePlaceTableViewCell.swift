//
//  PurchacePlaceTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 21/11/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class PurchacePlaceTableViewCell: UITableViewCell {
    
    private struct Constants {
        static let Margin = CGFloat( 8.0 )
    }

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
            tagListView.tag = tag
            tagListView.allowsRemoval = editMode
            tagListView.allowsCreation = editMode
        }
    }

    @IBOutlet weak var favoriteButton: UIButton! {
        didSet {
            favoriteButton.isHidden = !editMode
        }
    }
    
    var editMode: Bool = false {
        didSet {
            if editMode != oldValue {
                favoriteButton?.isHidden = !editMode
                tagListView?.allowsRemoval = editMode
                tagListView?.allowsCreation = editMode
            }
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
    
    override var tag: Int {
        didSet {
            tagListView?.tag = tag
        }
    }

    var width: CGFloat = CGFloat(320.0) {
        didSet {
            tagListView?.frame.size.width = width - Constants.Margin
            // print("Cell", tagListView.frame.size.width)
        }
    }

}
