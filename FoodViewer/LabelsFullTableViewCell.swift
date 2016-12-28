//
//  LabelsFullTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 24/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class LabelsFullTableViewCell: UITableViewCell {

    @IBOutlet weak var labelsTagListView: TagListView! {
        didSet {
            labelsTagListView.textFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            labelsTagListView.alignment = .center
            labelsTagListView.normalColorScheme = ColorSchemes.normal
            labelsTagListView.removableColorScheme = ColorSchemes.removable
            labelsTagListView.cornerRadius = 10
            
            // labelsTagListView.allowsRemoval = editMode
            // labelsTagListView.allowsCreation = editMode
            labelsTagListView.datasource = datasource
            labelsTagListView.delegate = delegate
            labelsTagListView.tag = tag
        }
    }
    
    var datasource: TagListViewDataSource? = nil {
        didSet{
            labelsTagListView?.datasource = datasource
        }
    }
    
    var delegate: TagListViewDelegate? = nil {
        didSet{
            labelsTagListView?.delegate = delegate
        }
    }
    
    var editMode: Bool = false {
        didSet{
            // labelsTagListView.allowsCreation = editMode
        }
    }
    
    override var tag: Int {
        didSet {
            labelsTagListView?.tag = tag
        }
    }

}
