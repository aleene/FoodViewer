//
//  ProducerTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 14/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class ProducerTableViewCell: UITableViewCell {

    fileprivate struct Constants {
        static let NoProduct = NSLocalizedString("No product defined", comment: "Text to indicate that no product is defined/setup.")
        static let EmptyString = ""
        static let SoldBy = NSLocalizedString("Sold by %@", comment: "Text to indicate the first shop the product is sold in.  ADD A TRAILING SPACE.")
        static let ProducedBy = NSLocalizedString("Produced in/by %@; ", comment: "Text to indicate the producer of the product.  ADD A TRAILING SPACE.")
        static let SoldIn = NSLocalizedString("Sold in ", comment: "Text to introduce where the product is sold.  ADD A TRAILING SPACE.")
        static let NoInformation = NSLocalizedString("No supply chain info", comment: "Text to indicate that no supply chain infor (origin, producer, etc.) are available.")
        static let Country = NSLocalizedString("%@", comment: "A list of countries seperated by a comma.")
        static let CountrySeparator = NSLocalizedString(", ", comment: "A separator of a list of countries. ADD A TRAILING SPACE")
        static let Separator = NSLocalizedString("; ", comment: "A sepator between sentence parts.  ADD A TRAILING SPACE.")
    }

    @IBOutlet weak var supplyChainLabel: UILabel!
    
    var product: FoodProduct? = nil {
        didSet {
            var textToDisplay = Constants.NoProduct
            if let newProduct = product {
                textToDisplay = Constants.EmptyString
                // "Produced by France, Sold in France by Shop"
                switch newProduct.manufacturingPlacesOriginal {
                case .available(let places):
                    textToDisplay += !places.isEmpty ? String(format: Constants.ProducedBy ,places[0]) : Constants.EmptyString
                default:
                    break
                }
                switch newProduct.countriesTranslated {
                case .available(let countries):
                    if !countries.isEmpty {
                        textToDisplay += Constants.SoldIn
                        for country in countries {
                            textToDisplay += String(format:Constants.Country, country)
                            if country == countries.last {
                                textToDisplay += Constants.Separator
                            } else {
                                textToDisplay += Constants.CountrySeparator
                            }
                        }
                    }
                default:
                    break
                }
                switch newProduct.storesOriginal {
                case .available(let stores):
                    textToDisplay += !stores.isEmpty ? String(format:Constants.SoldBy, stores[0]) : Constants.EmptyString
                default:
                    break
                }

            } else {
                textToDisplay = Constants.NoInformation
            }
            supplyChainLabel.text = textToDisplay
        }
    }
}
