//
//  TagListViewAddImageTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 11/11/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

protocol TagListViewAddImageCellDelegate: AnyObject {
/**
- parameters :
     - sender :
     - button : 
     */
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
            if #available(iOS 13.0, *) {
                tagListView.removableColorScheme = ColorScheme(text: .secondaryLabel, background: .secondarySystemFill, border: .systemBackground)
            } else {
                tagListView.removableColorScheme = ColorScheme(text: .white, background: .darkGray, border: .black)
            }
            tagListView.cornerRadius = 10
            tagListView.frame.size.width = self.frame.size.width
            
            tagListView.delegate = nil
            tagListView.tag = tag
            tagListView.prefixLabelText = nil
        }
    }
    
    func setup(datasource:TagListViewDataSource?, delegate:TagListViewAddImageCellDelegate?, editMode:Bool?, width:CGFloat?, tag:Int?, prefixLabelText:String?, scheme:ColorScheme?) {
        tagListView?.datasource = datasource
        tagListView?.delegate = delegate as? TagListViewDelegate
        self.delegate = delegate
        if let validEditMode = editMode {
            self.editMode = validEditMode
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

    private var editMode: Bool = false {
        didSet {
            takePhotoButton?.isHidden = !editMode
            selectFromCameraRollButton?.isHidden = !editMode
        }
    }
    
    private var delegate: TagListViewAddImageCellDelegate? = nil
    
    func reloadData() {
        tagListView.reloadData(clearAll: true)
    }
    
    func willDisappear() {
        tagListView.willDisappear()
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

