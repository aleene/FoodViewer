//
//  CountriesTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 13/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import TagListView

class CountriesTableViewCell: UITableViewCell {

    @IBOutlet weak var countriesTagListView: TagListView! {
        didSet {
            countriesTagListView.textFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            countriesTagListView.alignment = .Center
        }
    }

    
    var product: FoodProduct? = nil {
        didSet {
            if let countries = product?.countries {
                countriesTagListView.removeAllTags()
                for country in countries {
                    countriesTagListView.addTag(country)
                }
            }
        }
    }
    

}
