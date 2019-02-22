//
//  TagListViewTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 14/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

protocol TagListViewCellDelegate: class {
    
    // function to let the delegate know that a tag was single tapped
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedSingleTapOn tagListView:TagListView)
    // function to let the delegate know that a tag was double tapped
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedDoubleTapOn tagListView:TagListView)
}

class TagListViewTableViewCell: UITableViewCell {

    private struct Constants {
        static let Margin = CGFloat( 32.0 )
    }
    
    @IBOutlet weak var tagListView: TagListView! {
        didSet {
            tagListView.textFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            tagListView.alignment = .center
            tagListView.normalColorScheme = scheme
            tagListView.removableColorScheme = ColorSchemes.removable
            tagListView.cornerRadius = 10
            tagListView.removeButtonIsEnabled = true
            tagListView.clearButtonIsEnabled = true
            //tagListView.frame.size.width = self.frame.size.width
            
            tagListView.datasource = datasource
            tagListView.delegate = delegate as? TagListViewDelegate
            tagListView.allowsRemoval = editMode
            tagListView.allowsCreation = editMode
            tagListView.tag = tag
            tagListView.prefixLabelText = nil
            
            let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TagListViewTableViewCell.tagListViewSingleTapped))
            singleTapGestureRecognizer.numberOfTapsRequired = 1
            tagListView.addGestureRecognizer(singleTapGestureRecognizer)
            
            let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TagListViewTableViewCell.tagListViewDoubleTapped))
            doubleTapGestureRecognizer.numberOfTapsRequired = 2
            tagListView.addGestureRecognizer(doubleTapGestureRecognizer)

        }
    }
    
    var datasource: TagListViewDataSource? = nil {
        didSet {
            tagListView?.datasource = datasource
        }
    }
    
    var delegate: TagListViewCellDelegate? = nil {
        didSet {
            tagListView?.delegate = delegate as? TagListViewDelegate
        }
    }
    
    var editMode: Bool = false {
        didSet {
            tagListView?.allowsRemoval = editMode
            tagListView?.allowsCreation = editMode
        }
    }
    
    var width: CGFloat = CGFloat(320.0) {
        didSet {
            tagListView?.frame.size.width = width
            //print("TLV", tagListView.frame)
        }
    }
    
    var scheme = ColorSchemes.normal {
        didSet {
            tagListView?.normalColorScheme = scheme
        }
    }

    override var tag: Int {
        didSet {
            tagListView?.tag = tag
        }
    }
    
    var prefixLabelText: String? = nil {
        didSet {
            tagListView?.prefixLabelText = prefixLabelText
        }
    }
        
    func reloadData() {
        tagListView.reloadData(clearAll: true)
    }
    
    @objc func tagListViewDoubleTapped() {
        delegate?.tagListViewTableViewCell(self, receivedDoubleTapOn: tagListView)
    }

    @objc func tagListViewSingleTapped() {
        delegate?.tagListViewTableViewCell(self, receivedSingleTapOn: tagListView)
    }

}
