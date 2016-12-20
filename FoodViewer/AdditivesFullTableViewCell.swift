//
//  AdditivesFullTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 24/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class AdditivesFullTableViewCell: UITableViewCell {

    struct Constants {
        static let NoTag = NSLocalizedString("no additives detected", comment: "Text in a TagListView, when no additives (E-numbers) have been detected in the product ingredients.")
    }

    @IBOutlet weak var additivesTagListView: TagListView! {
        didSet {
            additivesTagListView.textFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            additivesTagListView.alignment = .center
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
    
    var editMode: Bool = false {
        didSet{
            additivesTagListView?.isEditable = editMode
        }
    }
    
    override var tag: Int {
        didSet {
            additivesTagListView.tag = tag
        }
    }
    
}
