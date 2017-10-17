//
//  nutrientsTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 18/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class NutrientsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemLabel: UILabel! {
        didSet {
            itemLabel.text = nutritionDisplayFactItem?.name != nil ? nutritionDisplayFactItem!.name! : TranslatableStrings.UnknownValue
        }
    }
    
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.text = nutritionDisplayFactItem?.value != nil ? nutritionDisplayFactItem!.value! : TranslatableStrings.UnknownValue
            textField.tag = tag
            textField.delegate = delegate
        }
    }

    @IBOutlet weak var unitButton: UIButton! {
        didSet {
            unitButton.setTitle(nutritionDisplayFactItem?.unit?.short(), for: .normal)
            unitButton.tag = tag
        }
    }
    
    var nutritionDisplayFactItem: NutrientsTableViewController.DisplayFact? = nil {
        didSet {
            if let item = nutritionDisplayFactItem {
                itemLabel.text = item.name != nil ? item.name! : TranslatableStrings.UnknownValue
                textField?.text = item.value != nil ? item.value! : TranslatableStrings.UnknownValue
                item.unit != nil ? unitButton.setTitle(item.unit!.short(), for: .normal) : unitButton.setTitle(TranslatableStrings.UnknownValue, for: .normal)
            }
        }
    }
    
    var editMode: Bool = false {
        didSet {
            unitButton.isEnabled = editMode
            if editMode {
                textField.backgroundColor = UIColor.groupTableViewBackground
                textField.layer.cornerRadius = 5
                textField.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
                textField.clipsToBounds = true
            } else {
                textField.layer.cornerRadius = 5
                textField.backgroundColor = UIColor.white
                textField.layer.borderColor = UIColor.white.cgColor
            }
        }
    }
    
    // The tag is used to identify, which Nutrient is being edited
    override var tag: Int {
        didSet {
            textField?.tag = tag
            unitButton?.tag = tag
        }
    }
    
    var delegate: NutrientsTableViewController? = nil {
        didSet {
            textField?.delegate = delegate
        }
    }
}
