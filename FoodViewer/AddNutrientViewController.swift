//
//  AddNutrientViewController.swift
//  FoodViewer
//
//  Created by arnaud on 11/11/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class AddNutrientViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var addedNutrientTuple: (String, String, NutritionFactUnit)? = nil
    
    var existingNutrients: [String]? = nil
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var nutrientsPickerView: UIPickerView! {
        didSet {
            nutrientsPickerView.delegate = self
            nutrientsPickerView.dataSource = self
            nutrientsPickerView.showsSelectionIndicator = true
        }
    }
    
    // MARK: - PickerView Datasource methods
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return OFFplists.manager.nutrients.count + 1
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // MARK: - PickerView delegate methods
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "" // NSLocalizedString("Select", comment: "First element of a pickerView, where the user has to select a nutrient.")
        } else {
            return OFFplists.manager.nutrients[row - 1].1
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row > 0 {
            addedNutrientTuple = OFFplists.manager.nutrients[row - 1]
        }
    }
    
}
