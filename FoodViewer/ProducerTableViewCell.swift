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
        static let NoProduct = NSLocalizedString("No product Defined.", comment: "Text to indicate that no product is defined/setup.")
        static let EmptyString = ""
        static let SoldBy = NSLocalizedString("Sold by %@", comment: "Text to indicate the first shop the product is sold in.")
        static let ProducedBy = NSLocalizedString("Produced in/by %@; ", comment: "Text to indicate the producer of the product.")
        static let SoldIn = NSLocalizedString("Sold in ", comment: "Text to introduce where the product is sold.")
        static let NoInformation = NSLocalizedString("No supply chain info.", comment: "Text to indicate that no supply chain infor (origin, producer, etc.) are available.")
        static let Comma = NSLocalizedString("%@, ", comment: "Just a comma to separate items.")
        static let Separator = NSLocalizedString("; ", comment: "A sepator between sentence parts.")
    }

    @IBOutlet weak var supplyChainLabel: UILabel!
    
    var product: FoodProduct? = nil {
        didSet {
            var textToDisplay = Constants.NoProduct
            if let newProduct = product {
                textToDisplay = Constants.EmptyString
                // "Produced by France, Sold in France by Shop"
                
                if let producerArray = newProduct.producer {
                    textToDisplay += !producerArray.isEmpty ? String(format: Constants.ProducedBy ,producerArray[0]) : Constants.EmptyString
                }
                if let countries = newProduct.countries {
                    if !countries.isEmpty {
                        textToDisplay += Constants.SoldIn
                        for listItem in countries {
                            for (_, listItemValue) in listItem {
                                textToDisplay += String(format:Constants.Comma, listItemValue)
                            }
                        }
                        textToDisplay += Constants.Separator
                    }
                }
                if let stores = newProduct.stores {
                    textToDisplay += !stores.isEmpty ? String(format:Constants.SoldBy, stores[0]) : Constants.EmptyString
                }

            } else {
                textToDisplay = Constants.NoInformation
            }
            supplyChainLabel.text = textToDisplay
        }
    }
}
