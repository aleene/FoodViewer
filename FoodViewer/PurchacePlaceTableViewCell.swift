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
    
    internal struct Notification {
        static let TagKey = "PurchacePlaceTableViewCell.Notification.Tag.Key"
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
            tagListView?.frame.size.width = editMode ? width - Constants.Margin - CGFloat(40.0) : width - Constants.Margin
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PurchacePlaceTableViewCell.tagListViewTapped))
            tapGestureRecognizer.numberOfTapsRequired = 2
            tagListView.addGestureRecognizer(tapGestureRecognizer)

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
            // tagListView?.frame.size.width = editMode ? width - Constants.Margin - CGFloat(40.0) : width - Constants.Margin
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
            // tagListView?.frame.size.width = editMode ? width - Constants.Margin - CGFloat(40.0) : width - Constants.Margin
            tagListView?.frame.size.width = width - Constants.Margin - CGFloat(40.0)
            // print("Cell", tagListView.frame.size.width)
        }
    }
    
    func tagListViewTapped() {
        let userInfo: [String:Any] = [Notification.TagKey:tag]
        NotificationCenter.default.post(name: .TagListViewTapped, object:nil, userInfo: userInfo)
    }
    

}

// Definition:
extension Notification.Name {
    static let PurchasePlaceTagListViewTapped = Notification.Name("TagListViewTableViewCell.Notification.PurchasePlaceTagListViewTapped")
}

