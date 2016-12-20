//
//  TracesFullTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 24/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class TracesFullTableViewCell: UITableViewCell {

    @IBOutlet weak var tracesTagList: TagListView! {
        didSet {
            tracesTagList.textFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            tracesTagList.alignment = .center
            tracesTagList.cornerRadius = 10
            tracesTagList.datasource = datasource
            tracesTagList.delegate = delegate
        }
    }
    
    var datasource: TagListViewDataSource? = nil {
        didSet{
            tracesTagList?.datasource = datasource
        }
    }
    
    var delegate: TagListViewDelegate? = nil {
        didSet{
            tracesTagList?.delegate = delegate
        }
    }
    
    var editMode: Bool = false {
        didSet{
            tracesTagList?.isEditable = editMode
        }
    }
    
    override var tag: Int {
        didSet {
            tracesTagList.tag = tag
        }
    }

}
