//
//  TagListViewLabelTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 05/10/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

class TagListViewLabelTableViewCell: UITableViewCell {
    
    private struct Constants {
        static let Margin = CGFloat( 8.0 )
    }
    
    @IBOutlet weak var newLabel: UILabel! {
        didSet {
            setLabelText()
        }
    }
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    private func setLabelText2() {
        categoryLabel?.text = categoryLabelText
    }

    private func setLabelText() {
        newLabel?.text = labelText
    }
    
    @IBOutlet weak var tagListView: TagListView! {
        didSet {
            tagListView?.textFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
            if #available(iOS 13.0, *) {
                tagListView.removableColorScheme = ColorScheme(text: .secondaryLabel, background: .secondarySystemFill, border: .systemBackground)
            } else {
                tagListView.removableColorScheme = ColorScheme(text: .white, background: .darkGray, border: .black)
            }
            tagListView?.cornerRadius = 10
            tagListView?.allowsRemoval = true
            tagListView?.clearButtonIsEnabled = true
            tagListView?.frame.size.width = self.frame.size.width
            
            tagListView?.tag = tag
            tagListView?.prefixLabelText = nil
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TagListViewTableViewCell.tagListViewDoubleTapped))
            tapGestureRecognizer.numberOfTapsRequired = 2
            tagListView?.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    func setup(datasource:TagListViewDataSource?, delegate:TagListViewDelegate?, editMode:Bool?, width:CGFloat?, tag:Int?, prefixLabelText:String?, scheme:ColorScheme?, text: String?, text2: String?) {
        tagListView?.datasource = datasource
        tagListView?.delegate = delegate
        if let validEditMode = editMode {
            self.tagListView?.allowsRemoval = validEditMode
            self.tagListView?.allowsCreation = validEditMode

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
        if let validText = text {
            labelText = validText
        }
        if let validText = text2 {
            categoryLabelText = validText
        }
        tagListView.reloadData(clearAll: true)
    }
    
    private var labelText: String = "" {
        didSet {
            setLabelText()
        }
    }

    private var categoryLabelText: String = "" {
        didSet {
            setLabelText2()
        }
    }

    func reloadData() {
        tagListView.reloadData(clearAll: true)
    }
    
    func willDisappear() {
        // remove the gestures that this class addded
        if let gestures = tagListView?.gestureRecognizers {
            for gesture in gestures {
                // remove double tap gesture
                if let tapGesture = gesture as? UITapGestureRecognizer,
                    tapGesture.numberOfTouchesRequired == 2 {
                    tagListView?.removeGestureRecognizer(gesture)
                }
            }
        }
        tagListView.willDisappear()
    }

}
