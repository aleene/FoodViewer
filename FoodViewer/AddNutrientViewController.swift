//
//  AddNutrientViewController.swift
//  FoodViewer
//
//  Created by arnaud on 11/11/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class AddNutrientViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // The nutrient that user wants to
    var addedNutrientTuple: (Nutrient, String, NutritionFactUnit)? = nil
    
    // The nutrients that are already assigned to the product
    var existingNutrients: [String] = [] {
        didSet {
            setupNutrients()
        }
    }
    
    // A list of all possible nutrients
    private var allNutrients: [(Nutrient, String, NutritionFactUnit)] = []

    // The list of nutrients filtered by the textFilter
    private var filteredNutrients: [(Nutrient, String, NutritionFactUnit)] = []
    
    
    private var textFilter: String = "" {
        didSet {
            filteredNutrients = textFilter.isEmpty ?
                allNutrients :
                allNutrients.filter({ $0.1.lowercased().contains(textFilter) })
        }
    }

    @IBOutlet weak var nutrientsPickerView: UIPickerView! {
        didSet {
            nutrientsPickerView.delegate = self
            nutrientsPickerView.dataSource = self
            nutrientsPickerView.showsSelectionIndicator = true
        }
    }
    
    @IBOutlet weak var filterTextField: UITextField!
    
    @IBOutlet weak var navItem: UINavigationItem!

    // MARK: - PickerView Datasource methods
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return filteredNutrients.count + 1
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // MARK: - PickerView delegate methods
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return ""
        } else {
            return filteredNutrients[row - 1].1
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row > 0 {
            addedNutrientTuple = filteredNutrients[row - 1]
        }
    }
    
    private func purgeNutrients() {
        // remove the existing nutrient(s) from the nutrients list
        for nutrient in existingNutrients {
            if let validIndex = allNutrients.firstIndex(where: { (s: (Nutrient, String, NutritionFactUnit)) -> Bool in
                s.1 == nutrient
            }){
                allNutrients.remove(at: validIndex)
            }
        }
    }

    private func setupNutrients() {
        allNutrients = OFFplists.manager.nutrients
        purgeNutrients()
    }

    @objc func textChanged(notification: Notification) {
        if let text = filterTextField.text {
            textFilter = text
            self.nutrientsPickerView.reloadAllComponents()
            addedNutrientTuple = filteredNutrients.first
        }
    }
    
    // MARK: - ViewController Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navItem.title = TranslatableStrings.Select
        
        filterTextField.placeholder = TranslatableStrings.FilterLanguagePlaceholder
        filterTextField.delegate = self
        textFilter = ""
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.textChanged(notification:)),
            name: UITextField.textDidChangeNotification,
            object: nil)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }

}

// MARK: - UITextFieldDelegate Functions

extension AddNutrientViewController: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder { textField.resignFirstResponder() }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // reset the filter
        if !textFilter.isEmpty {
            textFilter = ""
            self.nutrientsPickerView.reloadAllComponents()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
}
