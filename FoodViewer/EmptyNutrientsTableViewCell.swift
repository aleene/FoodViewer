//
//  EmptyNutrientsTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 06/03/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class EmptyNutrientsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tagListView: TagListView! {
        didSet {
            tagListView.textFont = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            tagListView.alignment = .center
            tagListView.cornerRadius = 10
            tagListView.datasource = self
        }
    }
    
    var availability: NutritionAvailability = .notIndicated {
        didSet {
            switch availability {
            case .perServing, .perStandardUnit, .perServingAndStandardUnit:
                tagListView.tagBackgroundColor = UIColor.green
            case .notOnPackage:
                tagListView.tagBackgroundColor = UIColor.orange
            case .notIndicated, .notAvailable:
                tagListView.tagBackgroundColor = UIColor.red
            }
        }
    }
}

extension EmptyNutrientsTableViewCell: TagListViewDataSource{

    // TagListView Datasource functions
    
    public func numberOfTagsIn(_ tagListView: TagListView) -> Int {
        return 1
    }
    
    public func tagListView(_ tagListView: TagListView, titleForTagAt index: Int) -> String {
        return availability.description()
    }

    
    /*
    /// Is it allowed to edit a Tag object at a given index?
    public func tagListView(_ tagListView: TagListView, canEditTagAt index: Int) -> Bool {
        return false
    }
    
    /// Is it allowed to move a Tag object at a given index?
    public func tagListView(_ tagListView: TagListView, canMoveTagAt index: Int) -> Bool {
        return false
    }
    /// The Tag object at the source index has been moved to a destination index.
    public func tagListView(_ tagListView: TagListView, moveTagAt sourceIndex: Int, to destinationIndex: Int) {
    }
    
    /// Called if the user wants to delete all tags
    public func didClear(_ tagListView: TagListView) {
    }
    
    /// Which text should be displayed when the TagListView is collapsed?
    public func tagListViewCollapsedText(_ tagListView: TagListView) -> String {
        return "Stub text"
    }
    */

}
