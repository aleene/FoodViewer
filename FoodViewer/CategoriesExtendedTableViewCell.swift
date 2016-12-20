//
//  CategoriesExtendedTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 27/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class CategoriesExtendedTableViewCell: UITableViewCell, TagListViewDataSource {
    
    fileprivate struct Constants {
        static let NoInformation = NSLocalizedString("no categories specified", comment: "Text in a TagListView, when no categories are available in the product data.") 
    }
        
    @IBOutlet weak var listTagListView: TagListView! {
        didSet {
            listTagListView.textFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            listTagListView.alignment = .center
            listTagListView.cornerRadius = 10
            listTagListView.datasource = self
        }
    }
        
    var tagList: [String]? = nil {
        didSet {
            if let list = tagList {
                if !list.isEmpty {
                    listTagListView.tagBackgroundColor = UIColor.green
                    /*
                    for listItem in list {
                        if listItem.contains(":") {
                            let tagView = listTagListView.addTag(listItem)
                            tagView.tagBackgroundColor = UIColor.blue
                        } else {
                            listTagListView.addTag(listItem)
                        }
                    }
                     */
                } else {
                    listTagListView.tagBackgroundColor = UIColor.orange
                }
            } else {
                listTagListView.tagBackgroundColor = UIColor.orange
            }
        }
    }

    // TagListView Datasource functions
    
    func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        if let list = tagList {
            if !list.isEmpty {
                return list.count
            } else {
                return 1
            }
        } else {
            return 1
        }
    }
    
    func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        if let list = tagList {
            if !list.isEmpty {
                return list[index]
                /*
                for listItem in list {
                    if listItem.contains(":") {
                        let tagView = listTagListView.addTag(listItem)
                        tagView.tagBackgroundColor = UIColor.blue
                    } else {
                        listTagListView.addTag(listItem)
                    }
                }
                 */
            } else {
                return Constants.NoInformation
            }
        } else {
            return Constants.NoInformation
        }
    }
    
}
