//
//  TagListViewDelegate.swift
//  ManagedTagListView
//
//  Created by arnaud on 28/12/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

// MARK: - TagListView Delegate Functions

public protocol TagListViewDelegate {
    // @objc optional func tagPressed(_ title: String, tagView: TagView, sender: TagListView) -> Void
    // @objc optional func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) -> Void
    func tagListView(_ tagListView: TagListView, didSelectTagAt index: Int)
    
    func tagListView(_ tagListView: TagListView, willSelectTagAt index: Int)
    
    func tagListView(_ tagListView: TagListView, didDeselectTagAt index: Int)
    
    func tagListView(_ tagListView: TagListView, willDeselectTagAt index: Int)
    
    func tagListView(_ tagListView: TagListView, willBeginEditingTagAt index: Int)
    
    func tagListView(_ tagListView: TagListView, didEndEditingTagAt index: Int)
    
    func tagListView(_ tagListView: TagListView, targetForMoveFromTagAt sourceIndex: Int,
                     toProposed proposedDestinationIndex: Int) -> Int
    
    func tagListView(_ tagListView: TagListView, didAddTagWith title: String)
    
    /// Called when the user returns for a given input.
    ///func tagListView(_ tagListView: TagListView, didEnter text: String)
    /// Called when the user tries to delete a tag at the given index.
    func tagListView(_ tagListView: TagListView, didDeleteTagAt index: Int)
    
    /// Called when the user changes the text in the textField.
    ///func tagListView(_ tagListView: TagListView, didChange text: String)
    /// Called when the TagListView did begin editing.
    ///func tagListViewDidBeginEditing(_ tagListView: TagListView)
    /// Called when the TagListView's content height changes.
    func tagListView(_ tagListView: TagListView, didChange height: CGFloat)
    
    func tagListView(_ tagListView: TagListView, willDisplay tagView: TagView, at index: Int) -> TagView?
}


extension TagListViewDelegate {
    
    public func tagListView(_ tagListView: TagListView, didSelectTagAt index: Int) {
    }
    
    public func tagListView(_ tagListView: TagListView, willSelectTagAt index: Int) {
    }
    
    public func tagListView(_ tagListView: TagListView, didDeselectTagAt index: Int) {
    }
    
    public func tagListView(_ tagListView: TagListView, willDeselectTagAt index: Int) {
    }
    
    public func tagListView(_ tagListView: TagListView, willBeginEditingTagAt index: Int) {
    }
    
    public func tagListView(_ tagListView: TagListView, didEndEditingTagAt index: Int) {
    }
    
    public func tagListView(_ tagListView: TagListView, targetForMoveFromTagAt sourceIndex: Int,
                            toProposed proposedDestinationIndex: Int) -> Int {
        return proposedDestinationIndex
    }
    
    public func tagListView(_ tagListView: TagListView, didAddTagWith title: String) {
    }
    
    /// Called when the user returns for a given input.
    ///func tagListView(_ tagListView: TagListView, didEnter text: String)
    /// Called when the user tries to delete a tag at the given index.
    public func tagListView(_ tagListView: TagListView, didDeleteTagAt index: Int) {
    }
    
    /// Called when the user changes the text in the textField.
    ///func tagListView(_ tagListView: TagListView, didChange text: String)
    /// Called when the TagListView did begin editing.
    ///func tagListViewDidBeginEditing(_ tagListView: TagListView)
    /// Called when the TagListView's content height changes.
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
    }
    
    public func tagListView(_ tagListView: TagListView, willDisplay tagView: TagView, at index: Int) -> TagView? {
        return nil
    }

}


