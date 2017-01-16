//
//  NoImageTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 12/04/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class NoImageTableViewCell: UITableViewCell {

    
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
                tagListView.normalColorScheme = ColorSchemes.normal
            case .noImageAvailable, .noData, .loadingFailed:
                tagListView.normalColorScheme = ColorSchemes.error
            case .loading:
                tagListView.normalColorScheme = ColorSchemes.none
            }
        }
    }
}

extension NoImageTableViewCell: TagListViewDataSource {

    // TagListView Datasource functions
    
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        return 1
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        return imageFetchStatus.description()
    }

}
