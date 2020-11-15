//
//  nutrientsTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 18/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

protocol NutrientsCellDelegate: class {
    
    func nutrientsTableViewCell(_ sender: NutrientsTableViewCell, receivedTapOn button:UIButton)
    
/**
Informs the delegate that the nutrient uint button has been tapped.

- parameters:
     - sender: the `NutrientsTableViewCell` that sent the call;
     - nutrient: the `Nutrient` that is shown cell. This is needed to identify the correct nutrient to update;
     - unit: the `NutritionFactUnit` with the current value
     - button: the button that has been tapped. Can be used to anchor a popOver;
     */
    func nutrientsTableViewCellUnit(_ sender: NutrientsTableViewCell, nutrient: Nutrient?, unit: NutritionFactUnit?, receivedTapOn button: UIButton)
}

class NutrientsTableViewCell: UITableViewCell {
    
// MARK: - Storybard elements
    
    @IBOutlet weak var itemLabel: UILabel! {
        didSet {
            itemLabel.text =  nutritionDisplayFactItem?.name ?? TranslatableStrings.UnknownValue
        }
    }
    
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField?.text = nutritionDisplayFactItem?.value ?? TranslatableStrings.UnknownValue
            textField?.tag = tag
            textField?.delegate = delegate as? UITextFieldDelegate
        }
    }

    @IBOutlet weak var unitButton: UIButton! {
        didSet {
            unitButton?.setTitle(nutritionDisplayFactItem?.unit?.short, for: .normal)
            unitButton?.tag = tag
        }
    }
    
    @IBAction func unitButtonTapped(_ sender: UIButton) {
        delegate?.nutrientsTableViewCellUnit(self, nutrient: nutritionDisplayFactItem?.nutrient, unit:nutritionDisplayFactItem?.unit, receivedTapOn: sender)
    }
    
    @IBOutlet weak var toggleViewModeButton: UIButton! {
        didSet {
            toggleViewModeButton.isHidden = true
            toggleViewModeButton.tag = tag
        }
    }
    
    @IBAction func toggleViewModeButtonTapped(_ sender: UIButton) {
        delegate?.nutrientsTableViewCell(self, receivedTapOn:sender)
    }
    
    var nutritionDisplayFactItem: NutrientsTableViewController.DisplayFact? = nil {
        didSet {
            if let item = nutritionDisplayFactItem {
                itemLabel.text = item.name ?? TranslatableStrings.UnknownValue
                textField?.text = item.value ?? TranslatableStrings.UnknownValue
                item.unit != nil ? unitButton.setTitle(item.unit!.short, for: .normal) : unitButton.setTitle(TranslatableStrings.UnknownValue, for: .normal)
            }
        }
    }
    
    var editMode: Bool = false {
        didSet {
            textField.layer.cornerRadius = 5
            if #available(iOS 13.0, *) {
                textField.backgroundColor = editMode ? .secondarySystemFill : .systemBackground
                textField?.layer.borderColor = editMode ? UIColor.gray.cgColor : UIColor.systemBackground.cgColor
                textField.textColor = editMode ? .secondaryLabel : .label
            } else {
                textField.backgroundColor = editMode ? .groupTableViewBackground : .white
                textField?.layer.borderColor = editMode ? UIColor.gray.cgColor : UIColor.white.cgColor
                textField.textColor = .white
            }

            if editMode {
                textField.clipsToBounds = true
                unitButton.setTitleColor(.systemGray, for: .normal)

            } else {
                textField.borderStyle = .none
                if #available(iOS 13.0, *) {
                    unitButton.setTitleColor(.label, for: .normal)
                } else {
                    unitButton.setTitleColor(.black, for: .normal)
                }

            }
            setupUnitButton()
        }
    }
    
    // The tag is used to identify, which Nutrient is being edited
    override var tag: Int {
        didSet {
            textField?.tag = tag
            unitButton?.tag = tag
            toggleViewModeButton?.tag = tag
        }
    }
    
    var unitButtonIsEnabled: Bool = false {
        didSet {
            setupUnitButton()
        }
    }
    
    private func setupUnitButton() {
        unitButton.isEnabled = unitButtonIsEnabled
        if unitButton.isEnabled {
            unitButton.setTitleColor(.systemGray, for: .normal)
        } else {
            if #available(iOS 13.0, *) {
                unitButton.setTitleColor(.label, for: .normal)
            } else {
                unitButton.setTitleColor(.black, for: .normal)
            }
        }
    }
    
    var delegate: NutrientsCellDelegate? = nil {
        didSet {
            textField?.delegate = delegate as? UITextFieldDelegate
        }
    }
    
    func willDisappear() {
        // remove any gestures when the cell disappears.
    }
}
