//
//  TagListViewCollectionViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 25/03/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

class TagListViewCollectionViewCell: UICollectionViewCell {
    
        private struct Constants {
            static let Margin = CGFloat( 32.0 )
        }
        
        /// The TagListView outlet of the cell
        @IBOutlet weak var tagListView: TagListView! {
            didSet {
                tagListView.textFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
                tagListView.alignment = .center
                if #available(iOS 13.0, *) {
                    tagListView.removableColorScheme = ColorScheme(text: .secondaryLabel, background: .secondarySystemFill, border: .systemBackground)
                } else {
                    tagListView.removableColorScheme = ColorScheme(text: .white, background: .darkGray, border: .black)
                }
                tagListView.cornerRadius = 10
                tagListView.prefixLabelText = nil
            }
        }
    /**
    - parameters :
         - datasource : The `TaglistViewDelegate` to be used by the `TagListView`
         - delegate : The `TaglistViewDataSource` to be used by the `TagListView`
         - width : The width of the `TagListView`  to use
         - tag : An identifier for the tag
    */
        func setup(datasource:TagListViewDataSource?, delegate:Any?, width:CGFloat?, tag:Int?) {
            tagListView?.datasource = datasource
            tagListView?.delegate = delegate as? TagListViewDelegate
            self.delegate = delegate as? TagListViewCellDelegate
            if let validWidth = width {
                tagListView?.frame.size.width = validWidth
            }
            if let validTag = tag {
                self.tag = validTag
                tagListView?.tag = validTag
            }
            tagListView.reloadData(clearAll: true)
        }
        
        private var delegate: TagListViewCellDelegate? = nil

    }
