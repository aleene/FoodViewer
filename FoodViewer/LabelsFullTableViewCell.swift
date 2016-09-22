//
//  LabelsFullTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 24/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class LabelsFullTableViewCell: UITableViewCell {

    fileprivate struct Constants {
        static let NoInformation = NSLocalizedString("no labels specified", comment: "Text in a TagListView, when no labels have been specified in the product data.")
    }

    
    var tagList: [String]? = nil {
        didSet {
            if let list = tagList {
                labelsTagListView.removeAllTags()
                if !list.isEmpty {
                    for listItem in list {
                        labelsTagListView.tagBackgroundColor = UIColor.green
                        if listItem.contains(":") {
                            let tagView = labelsTagListView.addTag(listItem)
                            tagView.tagBackgroundColor = UIColor.blue
                        } else {
                            labelsTagListView.addTag(listItem)
                        }
                    }
                } else {
                    labelsTagListView.addTag(Constants.NoInformation)
                    labelsTagListView.tagBackgroundColor = UIColor.orange
                }
            } else {
                labelsTagListView.removeAllTags()
                labelsTagListView.addTag(Constants.NoInformation)
                labelsTagListView.tagBackgroundColor = UIColor.orange
            }
        }
    }
    


    @IBOutlet weak var labelsTagListView: TagListView! {
        didSet {
            labelsTagListView.textFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            labelsTagListView.alignment = .center
            labelsTagListView.cornerRadius = 10
        }
    }

    
    func clean(_ list: [String]) -> [String] {
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
