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

    private struct Constants {
        static let NoInformation = "No labels specified"
    }

    
    var tagList: [String]? = nil {
        didSet {
            labelsTagListView.removeAllTags()
            if let list = tagList {
                let newList = clean(list)
                if !newList.isEmpty {
                    for listItem in newList {
                        labelsTagListView.addTag(listItem)
                    }
                    labelsTagListView.tagBackgroundColor = UIColor.greenColor()
                } else {
                    labelsTagListView.addTag(Constants.NoInformation)
                    labelsTagListView.tagBackgroundColor = UIColor.orangeColor()
                }
            } else {
                labelsTagListView.tagBackgroundColor = UIColor.orangeColor()
                labelsTagListView.addTag(Constants.NoInformation)
            }
        }
    }
    


    @IBOutlet weak var labelsTagListView: TagListView! {
        didSet {
            labelsTagListView.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            labelsTagListView.alignment = .Center
            labelsTagListView.cornerRadius = 10
        }
    }

    
    func clean(list: [String]) -> [String] {
        var newList: [String] = []
        if !list.isEmpty {
            for listItem in list {
                if listItem.characters.count > 0 {
                    newList.append(listItem)
                }
            }
        }
        return newList
    }

}
