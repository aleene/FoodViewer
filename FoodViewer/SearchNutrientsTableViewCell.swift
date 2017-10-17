//
//  SearchNutrientsTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 01/10/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

// IN principle no protocol is needed for letting a button segue into another vc
// But not with two buttons in separate cells, which go to the same vc

protocol SearchNutrientsCellDelegate: class {
    
    func searchNutrientsTableViewCell(_ sender: SearchNutrientsTableViewCell, receivedActionOnUnit button:UIButton)
    // func searchNutrientsTableViewCell(_ sender: SearchNutrientsTableViewCell, receivedActionOnCompare button:UIButton)
}

class SearchNutrientsTableViewCell: UITableViewCell {
    
    /*
 internal struct Notification {
        static let ChangeSearchNutrientUnitButtonTappedKey = "SearchNutrientsTableViewCell.Notification.ChangeSearchNutrientUnitButtonTapped.Key"
        static let ChangeSearchNutrientCompareButtonTappedKey = "SearchNutrientsTableViewCell.Notification.ChangeSearchNutrientCompareButtonTapped.Key"
    }
 */
    
    @IBOutlet weak var itemLabel: UILabel! {
        didSet {
            itemLabel.text = searchNutrition?.key ?? TranslatableStrings.UnknownValue
        }
    }
    
    @IBOutlet weak var comparisonOperatorButton: UIButton! {
        didSet {
            setCompareTitle()
        }
    }
    
    private func setCompareTitle() {
        comparisonOperatorButton.setTitle(searchNutrition?.searchOperator.rawValue ?? "?", for: .normal)
    }
    
    @IBOutlet weak var textField: UITextField! {
        didSet {
            setText()
            textField.tag = tag
            textField.delegate = delegate as? UITextFieldDelegate
        }
    }
    
    private func setText() {
        if let validValue = searchNutrition?.value {
            textField.text = "\(validValue)"
        } else {
            textField.text = TranslatableStrings.UnknownValue
        }
    }
    
    @IBOutlet weak var unitButton: UIButton! {
        didSet {
            unitButton.tag = tag
        }
    }
    
    @IBAction func unitButtonTapped(_ sender: UIButton) {
        delegate?.searchNutrientsTableViewCell(self, receivedActionOnUnit: sender)
        //let userInfo = [Notification.ChangeSearchNutrientUnitButtonTappedKey:sender]
        //NotificationCenter.default.post(name:.ChangeSearchNutrientUnitButtonTapped, object:nil, userInfo: userInfo)
    }
    
    private func setUnit() {
        if let validUnit = searchNutrition?.unit {
            unitButton.setTitle(validUnit.short(), for: .normal)
        } else {
            unitButton.setTitle(TranslatableStrings.UnknownValue, for: .normal)
        }
    }
    
    var searchNutrition: NutrimentSearch? = nil {
        didSet {
            if let item = searchNutrition {
                itemLabel.text = item.name
                setText()
                setUnit()
                setCompareTitle()
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
    
    var delegate: SearchNutrientsCellDelegate? = nil {
        didSet {
            textField?.delegate = delegate as? UITextFieldDelegate
        }
    }
}
/*
// Definition:
extension Notification.Name {
    static let ChangeSearchNutrientUnitButtonTapped = Notification.Name("SearchNutrientsTableViewCell.Notification.ChangeSearchNutrientUnitButtonTapped")
    static let ChangeSearchNutrientCompareButtonTapped = Notification.Name("SearchNutrientsTableViewCell.Notification.ChangeSearchNutrientCompareButtonTapped")
}
 */

