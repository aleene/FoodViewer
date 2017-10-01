//
//  TagListViewSwitchTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 22/09/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

class TagListViewSwitchTableViewCell: UITableViewCell {
    
    private struct Constants {
        static let Margin = CGFloat( 8.0 )
        struct SegmentedControl {
            static let Left = NSLocalizedString("Include", comment: "Test of a segmented control, which indicates that the corresponding tag(s) should be included in an advanced search")
            static let Right = NSLocalizedString("Exclude", comment: "Test of a segmented control, which indicates that the corresponding tag(s) should be included in an advanced search")
        }
    }
        
    internal struct Notification {
        static let TagKey = "TagListViewSwitchTableViewCell.Notification.Tag.Key"
        static let InclusionKey = "Inclusion"
    }
    
    @IBOutlet weak var segmentedControl: UISegmentedControl! {
        didSet {
            segmentedControl.setTitle(Constants.SegmentedControl.Left, forSegmentAt: 0)
            segmentedControl.setTitle(Constants.SegmentedControl.Right, forSegmentAt: 1)
            segmentedControl.selectedSegmentIndex = 0
        }
    }
    
    @IBAction func segmentedControlTapped(_ sender: UISegmentedControl) {
        inclusion = segmentedControl.selectedSegmentIndex == 0 ? true: false
        switchToggled()

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
            tagListView.frame.size.width = self.frame.size.width
                
            tagListView.datasource = datasource
            tagListView.delegate = delegate
            tagListView.allowsRemoval = editMode
            tagListView.allowsCreation = editMode
            tagListView.tag = tag
            tagListView.prefixLabelText = nil
                
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TagListViewTableViewCell.tagListViewTapped))
                tapGestureRecognizer.numberOfTapsRequired = 2
                tagListView.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    var inclusion: Bool = true {
        didSet {
            segmentedControl.selectedSegmentIndex = inclusion ? 0 : 1
        }
    }
    
    var datasource: TagListViewDataSource? = nil {
        didSet {
            tagListView?.datasource = datasource
        }
    }
        
    var delegate: TagListViewDelegate? = nil {
        didSet {
            tagListView?.delegate = delegate
        }
    }
        
    var editMode: Bool = false {
        didSet {
            tagListView?.allowsRemoval = editMode
            tagListView?.allowsCreation = editMode
            segmentedControl.isEnabled = editMode
        }
    }
        
    var width: CGFloat = CGFloat(320.0) {
        didSet {
            tagListView?.frame.size.width = width - Constants.Margin - segmentedControl.frame.size.width
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
        let userInfo: [String:Any] = [Notification.TagKey:tag]
        NotificationCenter.default.post(name: .TagListViewSwitchTapped, object:nil, userInfo: userInfo)
    }
    
    func switchToggled() {
        let userInfo: [String:Any] = [Notification.TagKey:tag, Notification.InclusionKey:inclusion]
        NotificationCenter.default.post(name: .TagListViewSwitchToggled, object:nil, userInfo: userInfo)
    }
    
}
    
    // Definition:
    extension Notification.Name {
        static let TagListViewSwitchTapped = Notification.Name("TagListViewSwitchTableViewCell.Notification.TagListViewSwitchTapped")
        static let TagListViewSwitchToggled = Notification.Name("TagListViewSwitchTableViewCell.Notification.TagListViewSwitchToggled")

}

