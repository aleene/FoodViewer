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
        static let CellContentViewMargin = CGFloat(8)
    }
    
    
    var productBrand: [String]? = nil {
        didSet {
            if let brand = productBrand?.first {
                brandLabel.text = brand 
            } else {
                brandLabel.text = TranslatableStrings.NoBrandsIndicated
            }
        }
    }

    @IBOutlet weak var brandLabel: UILabel!

}
