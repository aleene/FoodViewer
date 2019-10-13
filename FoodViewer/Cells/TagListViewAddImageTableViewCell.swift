//
//  TagListViewAddImageTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 11/11/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

protocol TagListViewAddImageCellDelegate: class {
    
    // function to let the delegate know that the switch changed
    //func tagListViewAddImageTableViewCell(_ sender: TagListViewAddImageTableViewCell, receivedDoubleTapOn tagListView:TagListView)
    func tagListViewAddImageTableViewCell(_ sender: TagListViewAddImageTableViewCell, receivedActionOnCamera button:UIButton)
    func tagListViewAddImageTableViewCell(_ sender: TagListViewAddImageTableViewCell, receivedActionOnCameraRoll button:UIButton)
}

class TagListViewAddImageTableViewCell: UITableViewCell {
    
    private struct Constants {
        static let Margin = CGFloat( 8.0 )
    }
    
    @IBOutlet weak var tagListView: TagListView! {
        didSet {
            tagListView.textFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
            tagListView.alignment = .center
            tagListView.normalColorScheme = scheme
            if #available(iOS 13.0, *) {
                tagListView.removableColorScheme = ColorScheme(text: .secondaryLabel, background: .secondarySystemFill, border: .systemBackground)
            } else {
                tagListView.removableColorScheme = ColorScheme(text: .white, background: .darkGray, border: .black)
            }
            tagListView.cornerRadius = 10
            tagListView.removeButtonIsEnabled = true
            tagListView.clearButtonIsEnabled = true
            tagListView.frame.size.width = self.frame.size.width
            
            tagListView.datasource = datasource
            tagListView.delegate = nil
            tagListView.allowsRemoval = false
            tagListView.allowsCreation = false
            tagListView.tag = tag
            tagListView.prefixLabelText = nil
            
            //let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TagListViewTableViewCell.tagListViewTapped))
            //tapGestureRecognizer.numberOfTapsRequired = 2
            //tagListView.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    var datasource: TagListViewDataSource? = nil {
        didSet {
            tagListView?.datasource = datasource
        }
    }
    
    var delegate: TagListViewAddImageCellDelegate? = nil {
        didSet {
            tagListView?.delegate = delegate as? TagListViewDelegate
        }
    }
    
    var editMode: Bool = false {
        didSet {
            takePhotoButton?.isHidden = !editMode
            selectFromCameraRollButton?.isHidden = !editMode
        }
    }
    
    var width: CGFloat = CGFloat(320.0) {
        didSet {
            tagListView?.frame.size.width = width - Constants.Margin
            // print("Cell", tagListView.frame.size.width)
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
    
    func tagListViewTapped() {
        // delegate?.tagListViewAddImageTableViewCell(self, receivedDoubleTapOn: tagListView)
    }

    @IBOutlet weak var takePhotoButton: UIButton! {
        didSet {
            takePhotoButton.isHidden = !editMode
        }
    }
    
    @IBAction func takePhotoButtonTapped(_ sender: UIButton) {
        delegate?.tagListViewAddImageTableViewCell(self, receivedActionOnCamera: sender)
    }
    
    @IBOutlet weak var selectFromCameraRollButton: UIButton! {
        didSet {
            selectFromCameraRollButton.isHidden = !editMode
        }
    }
    
    @IBAction func selectFromCamerRollButtonTapped(_ sender: UIButton) {
        delegate?.tagListViewAddImageTableViewCell(self, receivedActionOnCameraRoll: sender)
    }

}

