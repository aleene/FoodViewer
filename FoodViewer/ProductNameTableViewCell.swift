//
//  ProductNameTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 07/09/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class ProductNameTableViewCell: UITableViewCell {

    @IBOutlet weak var productNameLabel: UILabel!

    @IBOutlet weak var changeLanguageButton: UIButton!
    
    @IBAction func changeLanguageButtonTapped(sender: UIButton) {
        
    }
    
    private struct Constants {
        static let NoName = NSLocalizedString("no name specified", comment: "Text for productname, when no productname is available in the product data.")
        static let NoLanguage = NSLocalizedString("none", comment: "Text for language of product, when there is no laguage defined.")
    }

    var name: String? = nil {
        didSet {
            productNameLabel.text = (name != nil) && (name!.characters.count > 0) ? name! : Constants.NoName
        }
    }
    
    var language: String? = nil {
        didSet {
            let verboseLanguage = language != nil ? OFFplists.manager.translateLanguage(language!, language:NSLocale.preferredLanguages()[0])  : Constants.NoLanguage
            changeLanguageButton.setTitle(verboseLanguage, forState: UIControlState.Normal)
        }
    }
    
    var numberOfLanguages: Int = 0 {
        didSet {
            if numberOfLanguages > 1 {
                changeLanguageButton.enabled = true
            } else {
                changeLanguageButton.enabled = false
            }
        }
    }
}
