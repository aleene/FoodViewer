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
            tagListView.textFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
            tagListView.alignment = .center
            if #available(iOS 13.0, *) {
                tagListView.removableColorScheme = ColorScheme(text: .secondaryLabel, background: .secondarySystemFill, border: .systemBackground)
            } else {
                tagListView.removableColorScheme = ColorScheme(text: .white, background: .darkGray, border: .black)
            }
            tagListView.cornerRadius = 10
            tagListView.removeButtonIsEnabled = true
            tagListView.clearButtonIsEnabled = true            
            tagListView.prefixLabelText = nil
            
            let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TagListViewTableViewCell.tagListViewSingleTapped))
            singleTapGestureRecognizer.numberOfTapsRequired = 1
            tagListView.addGestureRecognizer(singleTapGestureRecognizer)
            
            let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TagListViewTableViewCell.tagListViewDoubleTapped))
            doubleTapGestureRecognizer.numberOfTapsRequired = 2
            tagListView.addGestureRecognizer(doubleTapGestureRecognizer)

        }
    }
    
    func setup(datasource:TagListViewDataSource?, delegate:TagListViewCellDelegate?, editMode:Bool?, width:CGFloat?, tag:Int?, prefixLabelText:String?, scheme:ColorScheme?) {
        tagListView?.datasource = datasource
        tagListView?.delegate = delegate as? TagListViewDelegate
        self.delegate = delegate
        if let validEditMode = editMode {
            tagListView?.allowsRemoval = validEditMode
            tagListView?.allowsCreation = validEditMode
        }
        if let validWidth = width {
            tagListView?.frame.size.width = validWidth
        }
        if let validTag = tag {
            self.tag = validTag
            tagListView?.tag = validTag
        }
        tagListView?.prefixLabelText = prefixLabelText
        if let validScheme = scheme {
            tagListView?.normalColorScheme = validScheme
        }
        tagListView.reloadData(clearAll: true)
    }
    
    func willDisappear() {
        // remove the gestures that this class addded
        if let gestures = tagListView?.gestureRecognizers {
            for gesture in gestures {
                // remove single tap gesture
                if let tapGesture = gesture as? UITapGestureRecognizer,
                    tapGesture.numberOfTouchesRequired == 1 {
                    tagListView?.removeGestureRecognizer(gesture)
                }
                // remove double tap gesture
                if let tapGesture = gesture as? UITapGestureRecognizer,
                    tapGesture.numberOfTouchesRequired == 2 {
                    tagListView?.removeGestureRecognizer(gesture)
                }
            }
        }
        tagListView.willDisappear()
    }
    
    
    private var delegate: TagListViewCellDelegate? = nil

    @objc func tagListViewDoubleTapped() {
        delegate?.tagListViewTableViewCell(self, receivedDoubleTapOn: tagListView)
    }

    @objc func tagListViewSingleTapped() {
        delegate?.tagListViewTableViewCell(self, receivedSingleTapOn: tagListView)
    }

}
