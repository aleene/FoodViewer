//
//  SearchNutrientsTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 01/10/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

class SearchNutrientsTableViewCell: UITableViewCell {
    
    internal struct Notification {
        static let ChangeSearchNutrientUnitButtonTappedKey = "SearchNutrientsTableViewCell.Notification.ChangeSearchNutrientUnitButtonTapped.Key"
        static let ChangeSearchNutrientCompareButtonTappedKey = "SearchNutrientsTableViewCell.Notification.ChangeSearchNutrientCompareButtonTapped.Key"
    }
    
    fileprivate struct Constants {
        static let UnknownValue = NSLocalizedString("?", comment: "Text when no value for nutritional facts have been specified.")
    }
    
    @IBOutlet weak var itemLabel: UILabel! {
        didSet {
            itemLabel.text = searchNutrition?.key ?? Constants.UnknownValue
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
            textField.delegate = delegate
        }
    }
    
    private func setText() {
        if let validValue = searchNutrition?.value {
            textField.text = "\(validValue)"
        } else {
            textField.text = Constants.UnknownValue
        }
    }
    
    @IBOutlet weak var unitButton: UIButton! {
        didSet {
            unitButton.tag = tag
        }
    }
    
    @IBAction func unitButtonTapped(_ sender: UIButton) {
        let userInfo = [Notification.ChangeSearchNutrientUnitButtonTappedKey:sender]
        NotificationCenter.default.post(name:.ChangeSearchNutrientUnitButtonTapped, object:nil, userInfo: userInfo)
    }
    
    private func setUnit() {
        if let validUnit = searchNutrition?.unit {
            unitButton.setTitle(validUnit.short(), for: .normal)
        } else {
            unitButton.setTitle(Constants.UnknownValue, for: .normal)
        }
    }
    
    var searchNutrition: NutrimentSearch? = nil {
        didSet {
            if let item = searchNutrition {
                itemLabel.text = item.key
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
    
    var delegate: NutrientsTableViewController? = nil {
        didSet {
            textField?.delegate = delegate
        }
    }
}

// Definition:
extension Notification.Name {
    static let ChangeSearchNutrientUnitButtonTapped = Notification.Name("SearchNutrientsTableViewCell.Notification.ChangeSearchNutrientUnitButtonTapped")
    static let ChangeSearchNutrientCompareButtonTapped = Notification.Name("SearchNutrientsTableViewCell.Notification.ChangeSearchNutrientCompareButtonTapped")
}

