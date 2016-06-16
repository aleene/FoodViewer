//
//  ProducerTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 14/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import TagListView

class ProducerTableViewCell: UITableViewCell {

    private struct Constants {
        static let NoProduct = "No product Defined"
        static let EmptyString = ""
        static let SoldBy = "sold by "
        static let By = " by "
        static let ProducedBy = "Produced by "
        static let At = " at "
        static let SoldIn = "Sold in "
        static let NoInformation = "No supply chain info."
    }

    @IBOutlet weak var supplyChainLabel: UILabel!
    
    var product: FoodProduct? = nil {
        didSet {
            var textToDisplay = Constants.NoProduct
            if let newProduct = product {
                textToDisplay = Constants.EmptyString
                // "Produced by France, Sold in France by Shop"
                
                if let producerArray = newProduct.producer {
                    textToDisplay += !producerArray.isEmpty ? Constants.ProducedBy + producerArray[0] : Constants.EmptyString
                }
                if let countries = newProduct.countries {
                    textToDisplay += !countries.isEmpty ? Constants.SoldIn + countries[0] : Constants.EmptyString
                }
                if let stores = newProduct.stores {
                    textToDisplay += !stores.isEmpty ? Constants.By + stores[0] : Constants.EmptyString
                }

            } else {
                textToDisplay = Constants.NoInformation
            }
            supplyChainLabel.text = textToDisplay
        }
    }
}
