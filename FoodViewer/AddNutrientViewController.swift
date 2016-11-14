//
//  AddNutrientViewController.swift
//  FoodViewer
//
//  Created by arnaud on 11/11/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class AddNutrientViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var addedNutrientKey :String? = nil
    
    @IBOutlet weak var nutrientsPickerView: UIPickerView!
    
    // MARK: - PickerView Datasource methods
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return OFFplists.manager.OFFnutrients?.count != nil ? OFFplists.manager.OFFnutrients!.count + 1 : 0
        default:
            return 0
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // MARK: - PickerView delegate methods
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let key = Locale.preferredLanguages[0]
        return row == 0 ? NSLocalizedString("Select Nutrient", comment: "Text of first element in a pickerView with all possible nutrients") :
            OFFplists.manager.nutrientText(atIndex: row - 1, languageCode: key)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row > 0 {
            addedNutrientKey = OFFplists.manager.nutrientVertex(atIndex: row - 1)?.key
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Select Nutrient", comment: "Title of view controller, which allows the adding of a nutrient")

        nutrientsPickerView.delegate = self
        nutrientsPickerView.dataSource = self
        nutrientsPickerView.showsSelectionIndicator = true
    }    

}
