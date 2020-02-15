//
//  TagListViewTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 14/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

protocol TagListViewCellDelegate: class {
/**
Function to let the delegate know that the tagListViewTableCell was single tapped

- Attention: The function is optional. Default is that no action will be taken.
- Parameters:
    - sender : the tagListTableViewCell that sent the call
    - tagListView - the tagListView that received the tap
*/
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedSingleTapOn tagListView:TagListView)
/**
Function to let the delegate know that a tag was double tapped
- Attention: The function is optional. Default is that no action will be taken.
- Parameters:
     - sender : the tagListTableViewCell that sent the call
     - tagListView: the tagListView that received the doubletap
*/
    func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedDoubleTapOn tagListView:TagListView)
}
/**
UITableView class that setups a horizontal multiline set of UIViews.
 
The class supports the possibility to edit the tags (add/delete), support gestures on individual views.
- Important: The dataSource protocol should be implemented to have the tags shown.
*/
class TagListViewTableViewCell: UITableViewCell {

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
            
            let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TagListViewTableViewCell.tagListViewSingleTapped))
            singleTapGestureRecognizer.numberOfTapsRequired = 1
            tagListView.addGestureRecognizer(singleTapGestureRecognizer)
            
            let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TagListViewTableViewCell.tagListViewDoubleTapped))
            doubleTapGestureRecognizer.numberOfTapsRequired = 2
            tagListView.addGestureRecognizer(doubleTapGestureRecognizer)

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
/**
Function called when the view disappears

The TagListView used in this class has gestures to its views. It is possible that gestures are a memory leak, so they should be removed when deallocating. This functions does this.
- Note: Should this be done by the `deinit`?
*/
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

extension TagListViewCellDelegate {
    
    public func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedSingleTapOn tagListView:TagListView) { }
    
    public func tagListViewTableViewCell(_ sender: TagListViewTableViewCell, receivedDoubleTapOn tagListView:TagListView) { }
}
