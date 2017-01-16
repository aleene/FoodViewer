//
//  ProductNameTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 07/09/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class ProductNameTableViewCell: UITableViewCell {


    @IBOutlet weak var changeLanguageButton: UIButton! {
        didSet {
            setLanguageButton()
        }
    }
    
    @IBAction func changeLanguageButtonTapped(_ sender: UIButton) { }
    
    @IBOutlet weak var nameTextView: UITextView! {
        didSet {
            setTextViewStyle()
        }
    }
    
    private func setLanguageButton() {
        changeLanguageButton?.isEnabled = editMode ? false : ( numberOfLanguages > 1 ? true : false )
    }
    
    private func setTextViewStyle() {
        nameTextView.layer.borderWidth = 0.5
        nameTextView?.delegate = delegate
        nameTextView?.tag = tag
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProductNameTableViewCell.nameTapped))
        tapGestureRecognizer.numberOfTapsRequired = 2
        nameTextView.addGestureRecognizer(tapGestureRecognizer)

        if editMode {
            nameTextView.backgroundColor = UIColor.groupTableViewBackground
            nameTextView.layer.cornerRadius = 5
            nameTextView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
            nameTextView.clipsToBounds = true
            // nameTextField.removeGestureRecognizer(tapGestureRecognizer)
        } else {
            nameTextView.backgroundColor = UIColor.white
            nameTextView.layer.borderColor = UIColor.white.cgColor
        }
        
        nameTextView?.sizeToFit()

    }
    

    fileprivate struct Constants {
        static let NoName = NSLocalizedString("no name specified", comment: "Text for productname, when no productname is available in the product data.")
        static let NoLanguage = NSLocalizedString("none", comment: "Text for language of product, when there is no language defined.")
    }
    
    var name: String? = nil {
        didSet {
            nameTextView.text = (name != nil) && (name!.characters.count > 0) ? name! : Constants.NoName
        }
    }
    
    var editMode: Bool = false {
        didSet {
            setLanguageButton()
            setTextViewStyle()
        }
    }
    
    var languageCode: String? = nil {
        didSet {
            let verboseLanguage = languageCode != nil ? OFFplists.manager.translateLanguage(languageCode!, language:Locale.preferredLanguages[0])  : Constants.NoLanguage
            changeLanguageButton.setTitle(verboseLanguage, for: UIControlState())
        }
    }
    
    var numberOfLanguages: Int = 0 {
        didSet {
            setTextViewStyle()
        }
    }
    
    var delegate: IdentificationTableViewController? = nil {
        didSet {
            nameTextView?.delegate = delegate
        }
    }
    
    override var tag: Int {
        didSet {
            nameTextView?.tag = tag
        }
    }

    func nameTapped() {
        NotificationCenter.default.post(name: .NameTextFieldTapped, object: nil)
    }
}

// Definition:
extension Notification.Name {
    static let NameTextFieldTapped = Notification.Name("ProductNameTableViewCell.Notification.NameTextFieldTapped")
}

