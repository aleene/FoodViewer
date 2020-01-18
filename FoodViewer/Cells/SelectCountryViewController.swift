//
//  SelectCountryViewController.swift
//  FoodViewer
//
//  Created by arnaud on 17/01/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//
// This class allows the user to pick a country from a prefined list of countries.
// This predefined list of countries shows only the countries not yet listed in the product.
// The user can filter the list of presented countries through entering a text string

import UIKit

class SelectCountryViewController: UIViewController {
//
// MARK: - External properties
//
    // The current countries assigned to the product
    // The contries are encodes as keys "en:english"
    var currentCountriesInterpreted: Tags? = nil {
        didSet {
            // if set the tags are converted to class Language items
            if let validTags = currentCountriesInterpreted {
                for tag in validTags.list {
                    var country = Language()
                    country.code = tag
                    country.name = OFFplists.manager.translateCountry(tag, language: Locale.preferredLanguages[0]) ?? TranslatableStrings.NoCountryDefined
                    countries.append(country)
                }
            }
            // remove the all the current countries from the picklist
            setupCountries()
        }
    }
    
    var selectedCountries: [String]? {
        // if no country has been selected, no changes to the countries (nil)
        guard let validCountry = selectedCountry else { return nil }
            
        var newCountries: [String] = []
        // add the existing remote countries
        newCountries = currentCountriesInterpreted?.list ?? []
        newCountries.append(validCountry)
        return newCountries
    }
    
//
// MARK: - Internal properties
//
    
// The class Language combines the key and local name of a country. The class should be renamed
    
    // The current countries as language array
    private var countries: [Language] = []

    // The current countries sorted on name in local language
    private var sortedCountries: [Language] = []
    
    // The sorted countries filtered on the text string
    private var filteredCountries: [Language] = []
    
    // The country the user wants to add
    private var selectedCountry: String? = nil

    private var textFilter: String = "" {
        didSet {
            filteredCountries = textFilter.isEmpty
                ? sortedCountries
                : sortedCountries.filter({ $0.name.lowercased().contains(textFilter) })
        }
    }
//
//  MARK : Interface elements
//
    
    @IBOutlet weak var pickerView: UIPickerView! {
        didSet {
            pickerView.dataSource = self
            pickerView.delegate = self
        }
    }
        
    @IBOutlet weak var countryTextField: UITextField! {
        didSet {
            countryTextField.delegate = self
        }
    }
    /*
        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            
            let myLabel = view == nil ? UILabel() : view as? UILabel
            
            var attributedRowText = NSMutableAttributedString()

            if filteredCountries.isEmpty {
                attributedRowText = NSMutableAttributedString(string: TranslatableStrings.NoLanguageDefined)
            //} else if row == 0 {
            //    attributedRowText = NSMutableAttributedString(string: Constants.Select)
            } else {
                attributedRowText = NSMutableAttributedString(string: filteredCountries[row].name)
            }

            myLabel?.textAlignment = .center
            
            attributedRowText.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Helvetica", size: 16.0)!, range: NSRange(location: 0 ,length:attributedRowText.length))
            myLabel!.attributedText = attributedRowText
            return myLabel!
        }
     */
    /*
    private func positionPickerView() {
        if let validCurrentCountry = selectedCountry {
            if let validIndex = filteredCountries.firstIndex(where: { (s: Language) -> Bool in
                s.code == validCurrentCountry
            }){
                countriesPickerView.selectRow(validIndex, inComponent: 0, animated: true)
            }
        }
    }
 */
        
    @IBOutlet weak var navItem: UINavigationItem! {
        didSet {
            navItem.title = TranslatableStrings.Select
        }
    }

    private func setupCountries() {
        guard sortedCountries.isEmpty else { return }
        purgeCountries()
        sortedCountries = sortedCountries.sorted(by: forward)
        textFilter = ""
    }
    
    // build up the country picklist the user is going to select from
    private func purgeCountries() {
        sortedCountries = OFFplists.manager.allCountries
        for country in countries {
            if let validIndex = sortedCountries.firstIndex( where: {
                (s: Language) -> Bool in
                    s.code == country.code
                }) {
                    sortedCountries.remove(at: validIndex)
            }
        }
    }

    private func forward(_ s1: Language, _ s2: Language) -> Bool {
        return s1.name < s2.name
    }

    @objc func textChanged(notification: Notification) {
        if let text = countryTextField.text {
            textFilter = text
            self.pickerView.reloadAllComponents()
            selectedCountry = filteredCountries.first?.code
        }
    }
    
//
// MARK: - ViewController Lifecycle
//
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
//
// MARK: - UIPickerViewDelegate Functions
//
extension SelectCountryViewController: UIPickerViewDelegate {
}
//
// MARK: - UIPickerViewDataSource Functions
//
extension SelectCountryViewController: UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCountry = filteredCountries[row].code
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
        
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return filteredCountries.isEmpty ? 1 : filteredCountries.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if filteredCountries.isEmpty {
            return TranslatableStrings.NoCountryDefined
        } else {
            return filteredCountries[row].name
        }
    }
}
//
// MARK: - UITextFieldDelegate Functions
//
extension SelectCountryViewController: UITextFieldDelegate {
        
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder { textField.resignFirstResponder() }
        return true
    }
        
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // reset the filter
        if !textFilter.isEmpty {
            textFilter = ""
            self.pickerView.reloadAllComponents()
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
