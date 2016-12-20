//
//  NoNutrientsImageTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 13/04/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//


import UIKit

class NoNutrientsImageTableViewCell: UITableViewCell, TagListViewDataSource {
    
    
    @IBOutlet weak var tagListView: TagListView! {
        didSet {
            tagListView.textFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            tagListView.alignment = .center
            tagListView.cornerRadius = 10
            tagListView.datasource = self
        }
    }
    
    var imageFetchStatus: ImageFetchResult = .noData {
        didSet {
            switch imageFetchStatus {
            case .success:
                tagListView.tagBackgroundColor = UIColor.green
            case .noImageAvailable, .noData, .loadingFailed:
                tagListView.tagBackgroundColor = UIColor.red
            case .loading:
                tagListView.tagBackgroundColor = UIColor.orange
            }
        }
    }
    
    // TagListView Datasource functions
    
    func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        return 1
    }
    
    func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        return imageFetchStatus.description()
    }
    

}
