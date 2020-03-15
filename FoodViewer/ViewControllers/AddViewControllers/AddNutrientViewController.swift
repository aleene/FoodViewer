//
//  AddNutrientViewController.swift
//  FoodViewer
//
//  Created by arnaud on 11/11/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import Foundation

protocol AddNutrientCoordinatorProtocol {
    /**
    Inform the protocol delegate that no shop has been selected.
    - Parameters:
         - sender : the `AddNutrientViewController` that called the function.
         - nutrientTuple : the tuple that has been added
    */
    func addNutrientViewController(_ sender:AddNutrientViewController, add nutrientTuple:(Nutrient, String, NutritionFactUnit)?)
    /**
    Inform the protocol delegate that no shop has been selected.
    - Parameters:
         - sender : the `AddNutrientViewController` that called the function.
    */
    func addNutrientViewControllerDidCancel(_ sender:AddNutrientViewController)
}

final class AddNutrientViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var protocolCoordinator: AddNutrientCoordinatorProtocol? = nil
    
    weak var coordinator: Coordinator? = nil

    public func configure(existing nutrients: [String]) {
        self.existingNutrients = nutrients
    }

    // The nutrient that user wants to
    private var addedNutrientTuple: (Nutrient, String, NutritionFactUnit)? = nil
    
    // The nutrients that are already assigned to the product
    private var existingNutrients: [String] = [] {
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
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar?.delegate = self
            searchBar?.placeholder = TranslatableStrings.FilterLanguagePlaceholder
        }
    }
    
    @IBOutlet weak var navItem: UINavigationItem! {
        didSet {
            navItem?.title = TranslatableStrings.Select
        }
    }
    
    @IBAction func doneBarButtonItemTapped(_ sender: UIBarButtonItem) {
        protocolCoordinator?.addNutrientViewController(self, add:addedNutrientTuple)
    }
    
    @IBAction func cancelBarButtonItemTapped(_ sender: UIBarButtonItem) {
        protocolCoordinator?.addNutrientViewControllerDidCancel(self)
    }

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

    /*
    @objc func textChanged(notification: Notification) {
        if let text = filterTextField.text {
            textFilter = text
            self.nutrientsPickerView.reloadAllComponents()
            addedNutrientTuple = filteredNutrients.first
        }
    }
 */
    
    // MARK: - ViewController Lifecycle
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // launch the filtering
        textFilter = ""
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }

}
//
// MARK: - UISearchBarDelegate Functions
//

extension AddNutrientViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        textFilter = searchText.lowercased()
        self.nutrientsPickerView.reloadAllComponents()
    }
}
/*
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
*/
