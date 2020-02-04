//
//  TagListViewDatasource.swift
//  ManagedTagListView
//
//  Created by arnaud on 28/12/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

// MARK: - TagListView DataSource Functions

public protocol TagListViewDataSource {
    
    /// What is the title for the Tag object at a given index?
    func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String
    
    func tagListView(_ tagListView: TagListView, colorSchemeForTagAt index: Int) -> ColorScheme?
    
    /// What are the number of Tag objects in the TagListView?
    func numberOfTagsIn(_ tagListView: TagListView) -> Int
    
    /// Called when the TagListView's content height changes.
    func tagListView(_ tagListView: TagListView, didChange height: CGFloat)

    /// Which text should be displayed when the TagListView is collapsed?
    func tagListViewCollapsedText(_ tagListView: TagListView) -> String
}


extension TagListViewDataSource {
    
    public func tagListViewCollapsedText(_ tagListView: TagListView) -> String {
        return "Collapsed Stub Title"
    }
    
    public func tagListView(_ tagListView: TagListView, didChange height: CGFloat) {
    }

    public func tagListView(_ tagListView: TagListView, colorSchemeForTagAt index: Int) -> ColorScheme? {
        return nil
    }

}
