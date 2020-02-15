//
//  TagListViewButtonTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 15/04/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

protocol TagListViewButtonCellDelegate: class {
/**
Function to let the delegate know that a tag was single tapped.
     
- parameters:
    - sender : the `TagListViewButtonTableViewCell` that is at the origin of the function call
    - tagListView : the tagListView that has been tapped on
 */
    func tagListViewButtonTableViewCell(_ sender: TagListViewButtonTableViewCell, receivedSingleTapOn tagListView:TagListView)
/**
Function to let the delegate know that a tag was double tapped.
         
- parameters:
    - sender : the `TagListViewButtonTableViewCell` that is at the origin of the function call
    - tagListView : the tagListView that has been tapped on
*/
    func tagListViewButtonTableViewCell(_ sender: TagListViewButtonTableViewCell, receivedDoubleTapOn tagListView:TagListView)
/**
Function to let the delegate know that the button was tapped.
             
- parameters:
    - sender : the `TagListViewButtonTableViewCell` that is at the origin of the function call
    - button : the tagListView that has been tapped on
*/
    func tagListViewButtonTableViewCell(_ sender: TagListViewButtonTableViewCell, receivedTapOn button:UIButton)
}
/**
 A `UITableViewClass` consisting of a `TagListView` and a `UIButton`.
 
- Important
There is no guarantee that when `setup()` is called, the TagListView and button are avalable. The `setup()` function will inititalise the internal variables. These in turn will initialise the outlets/actions. If these outlets/actions are not yet initialised, they can initailise themsleves later.
*/
class TagListViewButtonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var button: UIButton! {
        didSet {
            button?.isHidden = showButton
        }
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        delegate?.tagListViewButtonTableViewCell(self, receivedTapOn: sender)
    }
    
    @IBOutlet weak var tagListView: TagListView! {
        didSet {
            tagListView?.textFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
            tagListView?.alignment = .center
            tagListView?.frame.size.width = width
            tagListView?.cornerRadius = 10
            tagListView?.delegate = delegate as? TagListViewDelegate
            tagListView?.tag = tag
            tagListView?.reloadData(clearAll: true)
            if #available(iOS 13.0, *) {
                tagListView.removableColorScheme = ColorScheme(text: .secondaryLabel, background: .secondarySystemFill, border: .systemBackground)
            } else {
                tagListView.removableColorScheme = ColorScheme(text: .white, background: .darkGray, border: .black)
            }
}
    }
/**
Function that configures the `TagListViewButtonTableViewCell` class.
    
All necessary parameters should be set in one go, so we have a complete set at the start.
- Parameters:
     - datasource: The class that supports the `TagListView` datasource protocol.
     - delegate: The class that supports the `TagListView` delegate protocol. If the protocol functions are not needed, specify nil.
     - showButton: Show/hide the button.
     - width: The desired width of the cell
     - tag: An identifier for this cell
*/
    private struct Constants {
        static let Margin = CGFloat( 8.0 )
    }

    func setup(datasource:TagListViewDataSource?, delegate:Any?, showButton:Bool?, width:CGFloat?, tag:Int?) {
        self.datasource = datasource
        self.delegate = delegate as? TagListViewButtonCellDelegate
        self.tagListView?.delegate = delegate as? TagListViewDelegate
        if let validEditMode = showButton {
            self.showButton = validEditMode
        }
        if let validWidth = width {
            self.width = validWidth - 2 * Constants.Margin - ( button?.frame.size.width ?? 0 )
        }
        self.tag = tag ?? 0
        tagListView?.reloadData(clearAll: true)
    }
/**
Function called when the view disappears

The TagListView used in this class adds gestures to its views. It is possible that gestures are a memory leak, so they should be removed when deallocating. This functions does this.
- Note: Should this be done by the `deinit`?
*/
    func willDisappear() {
        tagListView?.willDisappear()
    }
    
    private var datasource: TagListViewDataSource? = nil {
        didSet {
            tagListView?.datasource = datasource
        }
    }

    private var delegate: TagListViewButtonCellDelegate? = nil {
        didSet {
            tagListView?.delegate = delegate as? TagListViewDelegate
        }
    }
        
    private var showButton: Bool = false {
        didSet {
            button?.isHidden = showButton
        }
    }
    
    private var width: CGFloat = 32.0 {
        didSet {
            tagListView?.frame.size.width = width
        }
    }
    
    public override var tag: Int {
        didSet {
            tagListView?.tag = tag        }
    }
}
// Default protocol implementations
extension TagListViewButtonCellDelegate {
    func tagListViewButtonTableViewCell(_ sender: TagListViewButtonTableViewCell, receivedSingleTapOn tagListView: TagListView) { }
    
    func tagListViewButtonTableViewCell(_ sender: TagListViewButtonTableViewCell, receivedDoubleTapOn tagListView: TagListView) { }
    
    func tagListViewButtonTableViewCell(_ sender: TagListViewButtonTableViewCell, receivedTapOn button: UIButton) { }
}
