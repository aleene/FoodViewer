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
    
    /// - parameter tagListView: the tagListView that iniated the call
    func tagListView(_ tagListView: TagListView, canTapTagAt index: Int) -> Bool

    /// - parameter tagListView: the tagListView that iniated the call
    func tagListView(_ tagListView: TagListView, didTapTagAt index: Int)

    /// - parameter tagListView: the tagListView that iniated the call
    func tagListView(_ tagListView: TagListView, didSelectTagAt index: Int)
    
    /// - parameter tagListView: the tagListView that iniated the call
    func tagListView(_ tagListView: TagListView, willSelectTagAt index: Int)
    
    /// - parameter tagListView: the tagListView that iniated the call
    func tagListView(_ tagListView: TagListView, didDeselectTagAt index: Int)
    
    /// - parameter tagListView: the tagListView that iniated the call
    func tagListView(_ tagListView: TagListView, willDeselectTagAt index: Int)
    
    /// - parameter tagListView: the tagListView that iniated the call
    func tagListView(_ tagListView: TagListView, didLongPressTagAt index: Int)

    /// - parameter tagListView: the tagListView that iniated the call
    func tagListView(_ tagListView: TagListView, willBeginEditingTagAt index: Int)
    
    /// - parameter tagListView: the tagListView that iniated the call
    func tagListView(_ tagListView: TagListView, didEndEditingTagAt index: Int)
    
    /// - parameter tagListView: the tagListView that iniated the call
    func tagListView(_ tagListView: TagListView, targetForMoveFromTagAt sourceIndex: Int,
                     toProposed proposedDestinationIndex: Int) -> Int
    
    /// - parameter tagListView: the tagListView that iniated the call
    func tagListView(_ tagListView: TagListView, didAddTagWith title: String)
        
    func tagListView(_ tagListView: TagListView, willDisplay tagView: TagView, at index: Int) -> TagView?
    
    /// Setting which determines whether the user can add tags
    /// If true a textfield to enter new tags will be added
    ///  - Attention: Default is false, no tags can be added
    /// - parameter tagListView: the tagListView that iniated the call
    func tagListViewCanAddTags(_ tagListView: TagListView) -> Bool
    
    /// The delegate wants to delete all tags
    /// - parameter tagListView: the tagListView that iniated the call
    func didDeleteAllTags(_ tagListView: TagListView)
    
    /// Delegate setting which determined whether specifc tags can be deleted
    /// If true a deleted icon will be added to each tag.
    /// - parameter tagListView: the tagListView that iniated the call
    func tagListViewCanDeleteTags(_ tagListView: TagListView) -> Bool

    /// Delegate setting which determined whether specifc tags can be deleted
    /// If true a deleted icon will be added to the tag at index.
    /// - Attention: Default is determined by false
    /// - parameter tagListView: the tagListView that iniated the call
    /// - parameter index: the index of the tag that can be deleted
    func tagListView(_ tagListView: TagListView, didDeleteTagAt index: Int)

    /// - parameter tagListView: the tagListView that iniated the call
    func tagListViewCanMoveTags(_ tagListView: TagListView) -> Bool

    /// Is it allowed to move a Tag object at a given index?
    /// - parameter tagListView: the tagListView that iniated the call
    func tagListView(_ tagListView: TagListView, canMoveTagAt index: Int) -> Bool
    
    /// The Tag object at the source index has been moved to a destination index.
    /// - parameter tagListView: the tagListView that iniated the call
    func tagListView(_ tagListView: TagListView, moveTagAt sourceIndex: Int, to destinationIndex: Int)

}

// The extension here defines all default implementations
extension TagListViewDelegate {

    public func tagListView(_ tagListView: TagListView, canTapTagAt index: Int) -> Bool {
        return false
    }

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
    
    func tagListView(_ tagListView: TagListView, canMoveTagAt index: Int) -> Bool {
        return false
    }
    func tagListView(_ tagListView: TagListView, moveTagAt sourceIndex: Int, to destinationIndex: Int) { }

    public func tagListView(_ tagListView: TagListView, targetForMoveFromTagAt sourceIndex: Int,
                            toProposed proposedDestinationIndex: Int) -> Int {
        return proposedDestinationIndex
    }
    
    public func tagListViewCanAddTags(_ tagListView: TagListView) -> Bool {
        return false
    }

    public func tagListView(_ tagListView: TagListView, didAddTagWith title: String) {
    }
    
    public func tagListView(_ tagListView: TagListView, willDisplay tagView: TagView, at index: Int) -> TagView? {
        return nil
    }
    
    public func tagListViewCanDeleteTags(_ tagListView: TagListView) -> Bool {
        return false
    }

    public func tagListView(_ tagListView: TagListView, didDeleteTagAt index: Int) {
    }
    
    public func didDeleteAllTags(_ tagListView: TagListView) {
    }

}


