//
//  SelectLanguageViewController.swift
//  FoodViewer
//
//  Created by arnaud on 03/09/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class SelectLanguageViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // These variables need to be set externally
    var productLanguageCodes: [String]? = nil
    var currentLanguageCode: String? = nil
    var primaryLanguageCode: String? = nil
    var selectedLanguageCode: String? = nil
    
    var sourcePage: Int = 0
    
    @IBOutlet weak var languagesPickerView: UIPickerView!
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if let validLanguageCodes = productLanguageCodes {
            selectedLanguageCode = validLanguageCodes[row]
        } else {
            selectedLanguageCode = nil
        }
    }
    
    // MARK: - Delegates and datasource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let validLanguageCodes = productLanguageCodes {
            return validLanguageCodes.count
        } else {
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let validLanguageCodes = productLanguageCodes {
            // MARK: TBD - do not show the codes, but the actual languages
            // show the language in the current iPad language
            // I could highlight the primary language
            return validLanguageCodes[row]
        } else {
            return ""
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
                
        languagesPickerView.dataSource = self
        languagesPickerView.delegate = self
        
        // MARK: TBD - I should move the picker to the current language
        if let validProductLanguageCodes = productLanguageCodes,
            let validCurrentLanguageCode = currentLanguageCode {
            let index = validProductLanguageCodes.indexOf(validCurrentLanguageCode)
            if let validIndex = index {
                languagesPickerView.selectRow(validIndex, inComponent: 0, animated: true)
            }         }
        
        title = NSLocalizedString("Select Language", comment: "Title of viewcontroller which allows the selecting of a product language.")
    }

}
