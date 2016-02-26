//
//  LabelsFullTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 24/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import TagListView

class LabelsFullTableViewCell: UITableViewCell {

    
    var tagList: [String]? = nil {
        didSet {
            if let list = tagList {
                labelsTagListView.removeAllTags()
                for listItem in list {
                    labelsTagListView.addTag(listItem)
                }
            }
        }
    }
    


    @IBOutlet weak var labelsTagListView: TagListView! {
        didSet {
            labelsTagListView.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            labelsTagListView.alignment = .Center
            labelsTagListView.tagBackgroundColor = UIColor.greenColor()
            labelsTagListView.cornerRadius = 10
        }
    }

}
