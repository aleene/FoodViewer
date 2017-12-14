//
//  SelectCompareViewController.swift
//  FoodViewer
//
//  Created by arnaud on 01/10/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

class SelectCompareViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private struct Constants {
        static let UnwindSegue = "Unwind Set Comparison Operator For Done Segue Identifier"
    }
    
    var nutrientRow: Int? = nil
    
    var currentCompareOperator: NutrimentSearch.Operator? = nil
    
    var currentNutritionFactKey: String? = nil
    
    var selectedCompareOperator: NutrimentSearch.Operator? = nil
    
    @IBOutlet weak var compareOperatorsPickerView: UIPickerView!
    
    @IBOutlet weak var navItem: UINavigationItem!

    // MARK: - PickerView Datasource methods
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 5
        default:
            return 0
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // MARK: - PickerView delegate methods
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row {
        case 0:
            return NutrimentSearch.Operator.lessThan.rawValue
        case 1:
            return NutrimentSearch.Operator.lessThanOrEqual.rawValue
        case 2:
            return NutrimentSearch.Operator.equal.rawValue
        case 3:
            return NutrimentSearch.Operator.greaterThanOrEqual.rawValue
        case 4:
            return NutrimentSearch.Operator.greaterThan.rawValue
        default:
            return "?"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row {
        case 0:
            selectedCompareOperator = .lessThan
        case 1:
            selectedCompareOperator = .lessThanOrEqual
        case 2:
            selectedCompareOperator = .equal
        case 3:
            selectedCompareOperator = .greaterThanOrEqual
        case 4:
            selectedCompareOperator = .greaterThan
        default:
            break
        }
        performSegue(withIdentifier: Constants.UnwindSegue, sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        compareOperatorsPickerView?.delegate = self
        compareOperatorsPickerView?.dataSource = self
        compareOperatorsPickerView?.showsSelectionIndicator = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navItem.title = TranslatableStrings.Select
    }
    

}
