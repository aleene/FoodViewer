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
    var languageCodes: [String]? = []
    var languages: [String:String]? = [:]
    var currentLanguageCode: String? = nil
    var primaryLanguageCode: String? = nil
    var selectedLanguageCode: String? = nil
    
    var sourcePage = 0
    
    @IBOutlet weak var languagesPickerView: UIPickerView!
    
    private struct Constants {
        static let NoLanguage = NSLocalizedString("none", comment: "Text for language of product, when there is no language defined.")
    }

    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedLanguageCode = languageCodes != nil ? languageCodes![row] : nil
    }
    
    // MARK: - Delegates and datasource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languageCodes != nil ? languageCodes!.count : 0
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let language = ((languageCodes != nil) && (languages != nil)) ? languages![languageCodes![row]] : nil
        return language != nil ? OFFplists.manager.translateLanguage(language!, language:NSLocale.preferredLanguages()[0])  : Constants.NoLanguage
        
        

    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
                
        languagesPickerView.dataSource = self
        languagesPickerView.delegate = self
        
        // MARK: TBD - I should move the picker to the current language
        if let validCurrentLanguageCode = currentLanguageCode,
        let validLanguageCodes = languageCodes {
            let index = validLanguageCodes.indexOf(validCurrentLanguageCode)
            if let validIndex = index {
                languagesPickerView.selectRow(validIndex, inComponent: 0, animated: true)
            }         }
        
        title = NSLocalizedString("Select Language", comment: "Title of viewcontroller which allows the selecting of a product language.")
    }

}
