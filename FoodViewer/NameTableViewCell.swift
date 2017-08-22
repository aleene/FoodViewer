//
//  NameTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 06/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class NameTableViewCell: UITableViewCell {
    
    fileprivate struct Constants {
        static let NoBrandsIndicated = NSLocalizedString("No brands indicated", comment: "Text in a tableview cell, when no brands are available in the product data.") 
        static let CellContentViewMargin = CGFloat(8)
    }
    
    
    var productBrand: [String]? = nil {
        didSet {
            if let brand = productBrand?.first {
                brandLabel.text = brand 
            } else {
                brandLabel.text = Constants.NoBrandsIndicated
            }
        }
    }

    @IBOutlet weak var brandLabel: UILabel!

}
