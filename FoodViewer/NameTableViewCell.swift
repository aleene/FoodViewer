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
            //print ("name xxx", self.frame)
        }

    }

    @IBOutlet weak var brandLabel: UILabel! {
        didSet {
            //print ("name yyy", self.frame)
        }
    }

}
