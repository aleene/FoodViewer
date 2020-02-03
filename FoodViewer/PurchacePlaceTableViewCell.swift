//
//  PurchacePlaceTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 21/11/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

protocol PurchacePlaceCellDelegate: class {
    
    // function to let the delegate know that the tagListView has been doubletapped
    func purchacePlaceTableViewCell(_ sender: PurchacePlaceTableViewCell, receivedDoubleTapOn tagListView: TagListView)
}

class PurchacePlaceTableViewCell: UITableViewCell {
    
    private struct Constants {
        static let Margin = CGFloat( 32.0 )
    }
    
    @IBOutlet weak var tagListView: TagListView! {
        didSet {
            tagListView.textFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
            tagListView.alignment = .center
            tagListView.normalColorScheme = ColorSchemes.normal
            if #available(iOS 13.0, *) {
                tagListView.removableColorScheme = ColorScheme(text: .secondaryLabel, background: .secondarySystemFill, border: .systemBackground)
            } else {
                tagListView.removableColorScheme = ColorScheme(text: .white, background: .darkGray, border: .black)
            }
            tagListView.cornerRadius = 10
            
            tagListView.datasource = datasource
            tagListView.delegate = delegate as? TagListViewDelegate
            tagListView.tag = tag
            tagListView?.frame.size.width = editMode ? width - Constants.Margin - CGFloat(40.0) : width - Constants.Margin
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PurchacePlaceTableViewCell.tagListViewTapped))
            tapGestureRecognizer.numberOfTapsRequired = 2
            tagListView.addGestureRecognizer(tapGestureRecognizer)

        }
    }
    
    func willDisappear() {
        // remove double tap gesture
        if let gestures = tagListView?.gestureRecognizers {
            for gesture in gestures {
                if let tapGesture = gesture as? UITapGestureRecognizer,
                    tapGesture.numberOfTouchesRequired == 2 {
                    tagListView?.removeGestureRecognizer(gesture)
                }
            }
        }
        tagListView?.willDisappear()
    }

    @IBOutlet weak var favoriteButton: UIButton! {
        didSet {
            favoriteButton.isHidden = !editMode
        }
    }
    
    var editMode: Bool = false {
        didSet {
            if editMode != oldValue {
                favoriteButton?.isHidden = !editMode
            }
            // tagListView?.frame.size.width = editMode ? width - Constants.Margin - CGFloat(40.0) : width - Constants.Margin
        }
    }
    
    var datasource: TagListViewDataSource? = nil {
        didSet {
            tagListView?.datasource = datasource
        }
    }
    
    var delegate: PurchacePlaceCellDelegate? = nil {
        didSet {
            tagListView?.delegate = delegate as? TagListViewDelegate
        }
    }
    
    override var tag: Int {
        didSet {
            tagListView?.tag = tag
        }
    }

    var width: CGFloat = CGFloat(320.0) {
        didSet {
            // tagListView?.frame.size.width = editMode ? width - Constants.Margin - CGFloat(40.0) : width - Constants.Margin
            tagListView?.frame.size.width = width - Constants.Margin - CGFloat(40.0)
            // print("Cell", tagListView.frame.size.width)
        }
    }
    
    @objc func tagListViewTapped() {
        delegate?.purchacePlaceTableViewCell(self, receivedDoubleTapOn: tagListView)
    }
    

}
