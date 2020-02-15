//
//  ProductCategoryTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 10/06/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class ProductCategoryTableViewCell: UITableViewCell {

    
    var belongsToCategory: Bool? = nil {
        didSet {
            setImage()
        }
    }
    
    var belongsToCategoryTitle: String? = nil {
        didSet {
            var belongsToCategoryLabelText = belongsToCategoryTitle != nil ? belongsToCategoryTitle! : TranslatableStrings.None
            // add a question mark
            belongsToCategoryLabelText += TranslatableStrings.QuestionMark
            belongsToCategoryLabel.text = belongsToCategoryLabelText
        }
    }
    
    @IBOutlet weak var belongsToCategoryLabel: UILabel!

    @IBOutlet weak var belongsToCategoryImage: UIImageView! {
        didSet {
            setImage()
        }
    }
    
    private func setImage() {
        guard belongsToCategory != nil else { return }
        belongsToCategoryImage?.image = belongsToCategory! ? UIImage.init(named: "OK") : UIImage.init(named: "NotOK")
    }

}
