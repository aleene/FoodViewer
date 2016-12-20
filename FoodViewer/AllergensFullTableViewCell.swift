//
//  AllergensFullTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 24/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class AllergensFullTableViewCell: UITableViewCell {

    @IBOutlet weak var allergensTagList: TagListView! {
        didSet {
            allergensTagList.textFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            allergensTagList.alignment = .center
            allergensTagList.cornerRadius = 10
            allergensTagList.datasource = datasource
            allergensTagList.delegate = delegate
        }
    }
    
    var datasource: TagListViewDataSource? = nil {
        didSet{
            allergensTagList?.datasource = datasource
        }
    }

    var delegate: TagListViewDelegate? = nil {
        didSet{
            allergensTagList?.delegate = delegate
        }
    }
    
    var editMode: Bool = false {
        didSet{
            allergensTagList?.isEditable = editMode
        }
    }
    
    override var tag: Int {
        didSet {
            allergensTagList.tag = tag
        }
    }

}
