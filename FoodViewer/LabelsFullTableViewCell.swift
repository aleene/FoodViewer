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
            labelsTagListView.tagBackgroundColor = .green
            labelsTagListView.cornerRadius = 10
            labelsTagListView.datasource = datasource
            labelsTagListView.delegate = delegate
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
            labelsTagListView?.isEditable = editMode
        }
    }
    
    override var tag: Int {
        didSet {
            labelsTagListView.tag = tag
        }
    }

}
