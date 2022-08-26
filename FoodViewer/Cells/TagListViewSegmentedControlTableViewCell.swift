//
//  TagListViewSegmentedControlTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 22/09/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit


protocol TagListViewSegmentedControlCellDelegate: AnyObject {
    
    // function to let the delegate know that the switch changed
    func tagListViewSegmentedControlTableViewCell(_ sender: TagListViewSegmentedControlTableViewCell, receivedActionOn segmentedControl:UISegmentedControl)
}


class TagListViewSegmentedControlTableViewCell: UITableViewCell {
    
    private struct Constants {
        static let Margin = CGFloat( 8.0 )
        struct SegmentedControlStrings {
            static let Left = TranslatableStrings.Exclude
            static let Right = TranslatableStrings.Include
        }
        struct SegmentedControlIndex {
            static let Excluded = 0
            static let Included = 1
        }
    }
    
    @IBOutlet weak var segmentedControl: UISegmentedControl! {
        didSet {
            segmentedControl.selectedSegmentIndex = Constants.SegmentedControlIndex.Included
            setupSegmentedControl()
        }
    }
    
    @IBAction func segmentedControlTapped(_ sender: UISegmentedControl) {
        inclusion = segmentedControl.selectedSegmentIndex == Constants.SegmentedControlIndex.Included ? true : false
        delegate?.tagListViewSegmentedControlTableViewCell(self, receivedActionOn:sender)
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
            //tagListView.frame.size.width = self.frame.size.width
                
            tagListView?.tag = tag
            tagListView?.prefixLabelText = nil
                
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TagListViewTableViewCell.tagListViewDoubleTapped))
                tapGestureRecognizer.numberOfTapsRequired = 2
                tagListView?.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    
    func setup(datasource:TagListViewDataSource?, delegate:TagListViewSegmentedControlCellDelegate?, editMode:Bool?, width:CGFloat?, tag:Int?, prefixLabelText:String?, scheme:ColorScheme?, inclusion:Bool?, inclusionEditAllowed:Bool?) {
        tagListView?.datasource = datasource
        tagListView?.delegate = delegate as? TagListViewDelegate
        self.delegate = delegate
        if let validEditMode = editMode {
            self.editMode = validEditMode
        }
        if let validWidth = width {
            let dus = validWidth - 2 * Constants.Margin - segmentedControl.frame.size.width
            tagListView?.frame.size.width = dus
        }
        if let validTag = tag {
            segmentedControl.tag = validTag
            tagListView?.tag = validTag
        }
        tagListView?.prefixLabelText = prefixLabelText
        if let validScheme = scheme {
            tagListView?.normalColorScheme = validScheme
        }
        if let validInclusion = inclusion {
            self.inclusion = validInclusion
        }
        if let validInclusionEditAllowed = inclusionEditAllowed {
            self.inclusionEditIsAllowed = validInclusionEditAllowed
        }
        tagListView.reloadData(clearAll: true)
    }

    private var inclusion: Bool = true {
           didSet {
               segmentedControl.selectedSegmentIndex = inclusion ? Constants.SegmentedControlIndex.Included : Constants.SegmentedControlIndex.Excluded
           }
       }
    
    private var inclusionEditIsAllowed: Bool = true {
        didSet {
            setupSegmentedControl()
        }
    }
        
    private var delegate: TagListViewSegmentedControlCellDelegate? = nil
    
    private func setupTagListViewDelegate() {
        if delegate is TagListViewDelegate {
            tagListView?.delegate = delegate as? TagListViewDelegate
        } else {
            assert(true, "TagListViewSegmentedControlTableViewCell Error: setup TagListViewDelegate")
        }
    }
    
    private var editMode: Bool = false {
        didSet {
            setupSegmentedControl()
        }
    }
    
    private func setupSegmentedControl() {
        segmentedControl.isEnabled = inclusionEditIsAllowed && editMode
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

