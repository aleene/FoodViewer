//
//  MainLanguageViewController.swift
//  FoodViewer
//
//  Created by arnaud on 29/01/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

class MainLanguageViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {

    
// MARK: - External properties
        
    var selectedLanguageCode: String? = nil
        
    var currentLanguageCodes: [String] = [] {
        didSet {
            setupLanguages()
        }
    }

    var editMode = false {
        didSet {
            setAddBarButtonItem()
        }
    }

    // The page where the call comes from
    var sourcePage = 0

    var primaryLanguageCode: String? = nil
        
// MARK: - Internal properties
        
    private var allLanguages: [Language] = []
        
    private var sortedLanguages: [Language] = []
    
    private var filteredLanguages: [Language] = []

    private var textFilter: String = "" {
        didSet {
            filteredLanguages = textFilter.isEmpty ?
                sortedLanguages :
                sortedLanguages.filter({ $0.name.lowercased().contains(textFilter) })
        }
    }

//  MARK : Interface elements
        
    
    @IBOutlet weak var languagesPickerView: UIPickerView! {
        didSet {
            languagesPickerView.dataSource = self
            languagesPickerView.delegate = self
        }
    }
    
    @IBOutlet weak var filterTextField: UITextField!
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    // MARK: - Delegates and datasource
        
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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
            return " "
        } else {
            return filteredLanguages[row - 1].name
        }
    }

    private func setupLanguages() {
        allLanguages = OFFplists.manager.allLanguages(Locale.preferredLanguages[0])
        purgeLanguageCodes()
        sortedLanguages = allLanguages.sorted(by: forward)
    }
        
    private func forward(_ s1: Language, _ s2: Language) -> Bool {
        return s1.name < s2.name
    }
        
    private func purgeLanguageCodes() {
        // remove the existing language(s) from the language list
        for validCode in currentLanguageCodes {
            if let validIndex = allLanguages.index(where: { (s: Language) -> Bool in
                s.code == validCode
            }){
                allLanguages.remove(at: validIndex)
            }
        }
    }
    
    private func setAddBarButtonItem() {
    //    if addBarButtonItem != nil {
    //        addBarButtonItem!.isEnabled = editMode
    //    }
    }
    
    @objc func textChanged(notification: Notification) {
        if let text = filterTextField.text {
            textFilter = text   
            self.languagesPickerView.reloadAllComponents()
            selectedLanguageCode = filteredLanguages.first?.code
        }
    }

    // MARK: - ViewController Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navItem.title = TranslatableStrings.SelectLanguage
        
        filterTextField.placeholder = TranslatableStrings.FilterLanguagePlaceholder
        filterTextField.delegate = self
        textFilter = ""
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.textChanged(notification:)),
            name: Notification.Name.UITextFieldTextDidChange,
            object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }

}

// MARK: - UITextFieldDelegate Functions

extension MainLanguageViewController: UITextFieldDelegate {
    
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
