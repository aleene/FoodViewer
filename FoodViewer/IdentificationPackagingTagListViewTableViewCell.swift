//
//  IdentificationPackagingTagListViewTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 16/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

import TagListView

class IdentificationPackagingTagListViewTableViewCell: UITableViewCell {

    @IBOutlet weak var tagListView: TagListView! {
        didSet {
            tagListView.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            tagListView.alignment = .Center
            tagListView.tagBackgroundColor = UIColor.greenColor()
            tagListView.cornerRadius = 10
            print("tagListView before bounds \(tagListView.bounds)")
            print("tagListView.super before bounds \(tagListView.superview!.bounds)")
        }
    }
    
    var tagList: [String]? = nil {
        didSet {
            if let list = tagList {
                tagListView.removeAllTags()
                for listItem in list {
                    tagListView.addTag(listItem)
                }
            }
            //tagListView.sizeToFit()
            //tagListView.superview!.sizeToFit()
            print("tagListView after bounds \(tagListView.bounds)")
            print("tagListView.super after bounds \(tagListView.superview!.bounds)")
        }
    }

}
