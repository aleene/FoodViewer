//
//  NoNutrientsImageTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 13/04/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//


import UIKit

class NoNutrientsImageTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var tagListView: TagListView! {
        didSet {
            tagListView.textFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            tagListView.alignment = .center
            tagListView.cornerRadius = 10
        }
    }
    
    var imageFetchStatus: ImageFetchResult = .noData {
        didSet {
            tagListView.removeAllTags()
            switch imageFetchStatus {
            case .success:
                tagListView.tagBackgroundColor = UIColor.green
            case .noImageAvailable, .noData, .loadingFailed:
                tagListView.tagBackgroundColor = UIColor.red
            case .loading:
                tagListView.tagBackgroundColor = UIColor.orange
            }
            tagListView.addTag(imageFetchStatus.description())
        }
    }
    
}
