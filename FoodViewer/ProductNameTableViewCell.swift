//
//  ProductNameTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 07/09/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class ProductNameTableViewCell: UITableViewCell {


    @IBOutlet weak var changeLanguageButton: UIButton!
    
    @IBAction func changeLanguageButtonTapped(_ sender: UIButton) { }
    
    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            setTextFieldStyle()
        }
    }
    
    private func setTextFieldStyle() {
        if editMode {
            nameTextField.borderStyle = .roundedRect
            nameTextField.layer.borderWidth = 1.0
            nameTextField.layer.borderColor = UIColor.black.cgColor

        } else {
            nameTextField.borderStyle = .roundedRect
            nameTextField.layer.borderWidth = 1.0
            nameTextField.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    fileprivate struct Constants {
        static let NoName = NSLocalizedString("no name specified", comment: "Text for productname, when no productname is available in the product data.")
        static let NoLanguage = NSLocalizedString("none", comment: "Text for language of product, when there is no language defined.")
    }
    
    var name: String? = nil {
        didSet {
            nameTextField.text = (name != nil) && (name!.characters.count > 0) ? name! : Constants.NoName
        }
    }
    
    var editMode: Bool = false {
        didSet {
            setTextFieldStyle()
        }
    }
    
    var language: String? = nil {
        didSet {
            let verboseLanguage = language != nil ? OFFplists.manager.translateLanguage(language!, language:Locale.preferredLanguages[0])  : Constants.NoLanguage
            changeLanguageButton.setTitle(verboseLanguage, for: UIControlState())
        }
    }
    
    var numberOfLanguages: Int = 0 {
        didSet {
            if numberOfLanguages > 1 {
                changeLanguageButton.isEnabled = true
            } else {
                changeLanguageButton.isEnabled = false
            }
        }
    }
}
