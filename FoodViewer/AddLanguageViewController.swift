//
//  AddLanguageViewController.swift
//  FoodViewer
//
//  Created by arnaud on 20/11/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class AddLanguageViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - External properties
    
    var selectedLanguageCode: String? = nil
    
    var currentLanguageCodes: [String] = [] {
        didSet {
            setupLanguages()
        }
    }
    
// MARK: - Internal properties
    
    private var allLanguages: [Language] = []
    
    private var sortedLanguages: [Language] = []
    
    private var filteredLanguages: [Language] = []

    var textFilter: String = "" {
        didSet {
            filteredLanguages = textFilter.isEmpty ? sortedLanguages :
                sortedLanguages.filter({ $0.name.lowercased().contains(textFilter) })        }
    }

//  MARK : Interface elements
    
    @IBOutlet weak var languagesPickerView: UIPickerView! {
        didSet {
            languagesPickerView.dataSource = self
            languagesPickerView.delegate = self
        }
    }
    
    @IBOutlet weak var navItem: UINavigationItem!

    @IBOutlet weak var languageTextField: UITextField!
    
// MARK: - Delegates and datasource
    
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedLanguageCode = row > 0 ? filteredLanguages[row - 1].code : nil
    }
    
    
    internal func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    internal func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return filteredLanguages.count + 1
    }
    
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if row == 0 {
            return ""
        } else {
            return filteredLanguages[row - 1].name
        }
    }
    
    private func setupLanguages() {
        allLanguages = OFFplists.manager.allLanguages
        purgeLanguageCodes()
        sortedLanguages = allLanguages.sorted(by: forward)
    }
    
    private func forward(_ s1: Language, _ s2: Language) -> Bool {
        return s1.name < s2.name
    }
    
    private func purgeLanguageCodes() {
        for code in currentLanguageCodes {
            if let validIndex = allLanguages.firstIndex(where: { (s: Language) -> Bool in
                s.code == code
            }){
                allLanguages.remove(at: validIndex)
            }
        }
    }

    @objc func textChanged(notification: Notification) {
        if let text = languageTextField.text {
            textFilter = text
            self.languagesPickerView.reloadAllComponents()
            selectedLanguageCode = filteredLanguages.first?.code
        }
    }

    // MARK: - ViewController Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navItem.title = TranslatableStrings.AddLanguage
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

extension AddLanguageViewController: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder { textField.resignFirstResponder() }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // reset the filter
        if !textFilter.isEmpty {
            textFilter = ""
            self.languagesPickerView.reloadAllComponents()
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


