//
//  TagListViewSegmentedControlTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 22/09/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit


protocol TagListViewSegmentedControlCellDelegate: class {
    
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
            //print(self.traitCollection)
            //if self.traitCollection.horizontalSizeClass == .compact {
                segmentedControl.setImage(UIImage.init(named: "NotOK"), forSegmentAt: Constants.SegmentedControlIndex.Excluded)
                segmentedControl.setImage(UIImage.init(named: "CheckMark"), forSegmentAt: Constants.SegmentedControlIndex.Included)
            //} else {0
             //   segmentedControl.setTitle(Constants.SegmentedControlStrings.Left, forSegmentAt: Constants.SegmentedControlIndex.Excluded)
             //   segmentedControl.setTitle(Constants.SegmentedControlStrings.Right, forSegmentAt: Constants.SegmentedControlIndex.Included)
            //}
            segmentedControl.selectedSegmentIndex = Constants.SegmentedControlIndex.Included
            segmentedControl.isEnabled = allowInclusionEdit && editMode
        }
    }
    
    @IBAction func segmentedControlTapped(_ sender: UISegmentedControl) {
        inclusion = segmentedControl.selectedSegmentIndex == Constants.SegmentedControlIndex.Included ? true : false
        delegate?.tagListViewSegmentedControlTableViewCell(self, receivedActionOn:sender)
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
            setupTagListViewDelegate()
            tagListView.allowsRemoval = editMode
            tagListView.allowsCreation = editMode
            tagListView.tag = tag
            tagListView.prefixLabelText = nil
                
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TagListViewTableViewCell.tagListViewDoubleTapped))
                tapGestureRecognizer.numberOfTapsRequired = 2
                tagListView.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    var inclusion: Bool = true {
        didSet {
            segmentedControl.selectedSegmentIndex = inclusion ? Constants.SegmentedControlIndex.Included : Constants.SegmentedControlIndex.Excluded
        }
    }
    
    var allowInclusionEdit: Bool = true {
        didSet {
            segmentedControl.isEnabled = allowInclusionEdit && editMode
        }
    }

    
    var datasource: TagListViewDataSource? = nil {
        didSet {
            tagListView?.datasource = datasource
        }
    }
        
    var delegate: TagListViewSegmentedControlCellDelegate? = nil {
        didSet {
            setupTagListViewDelegate()
        }
    }
    
    private func setupTagListViewDelegate() {
        if delegate is TagListViewDelegate {
            tagListView?.delegate = delegate as? TagListViewDelegate
        } else {
            assert(true, "TagListViewSegmentedControlTableViewCell Error: setup TagListViewDelegate")
        }
    }
    
    var editMode: Bool = false {
        didSet {
            tagListView?.allowsRemoval = editMode
            tagListView?.allowsCreation = editMode
            segmentedControl.isEnabled = allowInclusionEdit && editMode
        }
    }
    
    /*
    var width: CGFloat = CGFloat(320.0) {
        didSet {
            // also correct for the clear tags button
            tagListView?.frame.size.width = width - 2 * Constants.Margin - segmentedControl.frame.size.width
        }
    }
     */
        
    var scheme = ColorSchemes.normal {
        didSet {
            tagListView?.normalColorScheme = scheme
        }
    }
        
    override var tag: Int {
        didSet {
            tagListView?.tag = tag
            segmentedControl.tag = tag
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

}
    
