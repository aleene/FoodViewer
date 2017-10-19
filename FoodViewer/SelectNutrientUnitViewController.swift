//
//  SelectNutrientUnitViewController.swift
//  FoodViewer
//
//  Created by arnaud on 16/01/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

class SelectNutrientUnitViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    private struct Constants {
        static let UnwindSegue = "Unwind Set Nutrient Unit"
    }

    var nutrientRow: Int? = nil
    
    var currentNutritionUnit: NutritionFactUnit? = nil
    
    var currentNutritionFactKey: String? = nil
    
    var selectedNutritionUnit: NutritionFactUnit? = nil
    
    @IBOutlet weak var nutrientUnitsPickerView: UIPickerView!
    
    // MARK: - PickerView Datasource methods
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return currentNutritionFactKey != nil ? NutritionFactUnit.caseCount(key: currentNutritionFactKey!) : NutritionFactUnit.countCases()
        default:
            return 0
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // MARK: - PickerView delegate methods
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return currentNutritionFactKey != nil ? NutritionFactUnit(rawValue:NutritionFactUnit.value(for: row, and:currentNutritionFactKey!))?.short() : NutritionFactUnit(rawValue: row)?.short()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedNutritionUnit = currentNutritionFactKey != nil ? NutritionFactUnit(rawValue:NutritionFactUnit.value(for: row, and:currentNutritionFactKey!)) : NutritionFactUnit(rawValue: row)
        performSegue(withIdentifier: Constants.UnwindSegue, sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = TranslatableStrings.Select
        
        nutrientUnitsPickerView?.delegate = self
        nutrientUnitsPickerView?.dataSource = self
        nutrientUnitsPickerView?.showsSelectionIndicator = true
    }

}
