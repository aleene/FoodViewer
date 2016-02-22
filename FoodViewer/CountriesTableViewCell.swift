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

    private struct Constants {
        static let NoProduct = "No product Defined"
        static let EmptyString = ""
        static let SoldBy = "sold by "
        static let At = " at "
        static let In = " in "
        static let NoInformation = "No sales information available."
    }


    @IBOutlet weak var purchaseLocationLabel: UILabel!
    
    var product: FoodProduct? = nil {
        didSet {
            var textToDisplay = Constants.NoProduct
            if let newProduct = product {
                textToDisplay = Constants.EmptyString
                if let stores = newProduct.stores {
                        textToDisplay += !stores.isEmpty ? Constants.SoldBy + stores[0] : Constants.EmptyString
                }
                if let locations = newProduct.purchaseLocation {
                    textToDisplay += !locations.isEmpty ? Constants.At + locations[0] : Constants.EmptyString
                }
                if let countries = newProduct.countries {
                    textToDisplay += !countries.isEmpty ? Constants.In + countries[0] : Constants.EmptyString
                }
            } else {
                textToDisplay = Constants.NoInformation
            }
            purchaseLocationLabel.text = textToDisplay
        }
    }
    

}
