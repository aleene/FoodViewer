//
//  TagListViewDelegate.swift
//  ManagedTagListView
//
//  Created by arnaud on 28/12/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

// MARK: - TagListView Delegate Functions

public protocol TagListViewDelegate {
    
    func tagListView(_ tagListView: TagListView, didTapTagAt index: Int)

    func tagListView(_ tagListView: TagListView, didSelectTagAt index: Int)
    
    func tagListView(_ tagListView: TagListView, willSelectTagAt index: Int)
    
    func tagListView(_ tagListView: TagListView, didDeselectTagAt index: Int)
    
    func tagListView(_ tagListView: TagListView, willDeselectTagAt index: Int)
    
    func tagListView(_ tagListView: TagListView, didLongPressTagAt index: Int)

    func tagListView(_ tagListView: TagListView, willBeginEditingTagAt index: Int)
    
    func tagListView(_ tagListView: TagListView, didEndEditingTagAt index: Int)
    
    func tagListView(_ tagListView: TagListView, targetForMoveFromTagAt sourceIndex: Int,
                     toProposed proposedDestinationIndex: Int) -> Int
    
    func tagListView(_ tagListView: TagListView, didAddTagWith title: String)
    
    
    /// Called when the user changes the text in the textField.
    ///func tagListView(_ tagListView: TagListView, didChange text: String)
    /// Called when the TagListView did begin editing.
    ///func tagListViewDidBeginEditing(_ tagListView: TagListView)
    /// Called when the TagListView's content height changes.
    
    func tagListView(_ tagListView: TagListView, willDisplay tagView: TagView, at index: Int) -> TagView?
    

    func tagListViewCanAddTags(_ tagListView: TagListView) -> Bool
    
    func tagListViewCanDeleteAllTags(_ tagListView: TagListView) -> Bool

    /// Called if the user wants to delete all tags
    func didDeleteAllTags(_ tagListView: TagListView)
    
    func tagListViewCanDeleteTags(_ tagListView: TagListView) -> Bool

    /// Is it allowed to edit a Tag object at a given index?
    func tagListView(_ tagListView: TagListView, canDeleteTagAt index: Int) -> Bool

    /// Called when the user returns for a given input.
    ///func tagListView(_ tagListView: TagListView, didEnter text: String)
    /// Called when the user tries to delete a tag at the given index.
    func tagListView(_ tagListView: TagListView, didDeleteTagAt index: Int)

    func tagListViewCanMoveTags(_ tagListView: TagListView) -> Bool

    /// Is it allowed to move a Tag object at a given index?
    func tagListView(_ tagListView: TagListView, canMoveTagAt index: Int) -> Bool
    
    /// The Tag object at the source index has been moved to a destination index.
    func tagListView(_ tagListView: TagListView, moveTagAt sourceIndex: Int, to destinationIndex: Int)

}


extension TagListViewDelegate {
    
    public func tagListView(_ tagListView: TagListView, didTapTagAt index: Int) {
    }

    public func tagListView(_ tagListView: TagListView, didSelectTagAt index: Int) {
    }
    
    public func tagListView(_ tagListView: TagListView, willSelectTagAt index: Int) {
    }
    
    public func tagListView(_ tagListView: TagListView, didDeselectTagAt index: Int) {
    }
    
    public func tagListView(_ tagListView: TagListView, willDeselectTagAt index: Int) {
    }
    
    public func tagListView(_ tagListView: TagListView, didLongPressTagAt index: Int) {
    }

    public func tagListView(_ tagListView: TagListView, willBeginEditingTagAt index: Int) {
    }
    
    public func tagListView(_ tagListView: TagListView, didEndEditingTagAt index: Int) {
    }
    
    public func tagListViewCanMoveTags(_ tagListView: TagListView) -> Bool {
        return false
    }

    public func tagListView(_ tagListView: TagListView, targetForMoveFromTagAt sourceIndex: Int,
                            toProposed proposedDestinationIndex: Int) -> Int {
        return proposedDestinationIndex
    }
    
    public func tagListViewCanAddTags(_ tagListView: TagListView) -> Bool {
        return false
    }

    public func tagListView(_ tagListView: TagListView, didAddTagWith title: String) {
    }
    
    func tagListViewCanDeleteAllTags(_ tagListView: TagListView) -> Bool {
        return false
    }

    public func tagListView(_ tagListView: TagListView, canDeleteTagAt index: Int) -> Bool {
        return false
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
    
    public func tagListView(_ tagListView: TagListView, willDisplay tagView: TagView, at index: Int) -> TagView? {
        return nil
    }

    /// Called if the user wants to delete all tags
    public func didDeleteAllTags(_ tagListView: TagListView) {
    }
    
    

}


