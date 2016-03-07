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
        static let NoInformation = "no labels specified"
    }

    
    var tagList: [[String: String]]? = nil {
        didSet {
            if let list = tagList {
                labelsTagListView.removeAllTags()
                if !list.isEmpty {
                    for listItem in list {
                        for (_, listItemValue) in listItem {
                            labelsTagListView.addTag(listItemValue)
                        }
                    }
                    labelsTagListView.tagBackgroundColor = UIColor.greenColor()
                } else {
                    labelsTagListView.addTag(Constants.NoInformation)
                    labelsTagListView.tagBackgroundColor = UIColor.orangeColor()
                }
            } else {
                labelsTagListView.removeAllTags()
                labelsTagListView.addTag(Constants.NoInformation)
                labelsTagListView.tagBackgroundColor = UIColor.orangeColor()
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
