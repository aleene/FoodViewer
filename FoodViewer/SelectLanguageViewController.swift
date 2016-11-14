//
//  SelectLanguageViewController.swift
//  FoodViewer
//
//  Created by arnaud on 03/09/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class SelectLanguageViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - External properties
    
    var languageCodes: [String] = []
    var currentLanguageCode: String? = nil {
        didSet {
            selectedLanguageCode = currentLanguageCode
        }
    }
    var primaryLanguageCode: String? = nil
    var selectedLanguageCode: String? = nil

    var editMode = false {
        didSet {
            setupAddLanguageButton()
        }
    }
    
    var sourcePage = 0

    // MARK: - Internal properties
    
    private var allLanguages: [Language] = OFFplists.manager.allLanguages(Locale.preferredLanguages[0])

    private var addLanguage = false {
        didSet {
            setupAddLanguageButton()
        }
    }
    
    private func setupAddLanguageButton() {
        if addLanguageButton != nil {
            if addLanguage {
                addLanguageButton.setTitle(NSLocalizedString("Finish Add", comment: "Title of a button to finish adding languages"), for: .normal)
            } else {
                addLanguageButton.setTitle(NSLocalizedString("Add Languages", comment: "Title of a button allowing to add languages"), for: .normal)
            }
            // make the button usable, when in editMode
            addLanguageButton.isHidden = !editMode
        }
    }
    
    fileprivate struct Constants {
        static let NoLanguage = NSLocalizedString("none", comment: "Text for language of product, when there is no language defined.")
    }

    @IBOutlet weak var languagesPickerView: UIPickerView!
    
    @IBOutlet weak var addLanguageButton: UIButton! {
        didSet {
            setupAddLanguageButton()
        }
    }

    
    @IBAction func addLanguageButtonTapped(_ sender: UIButton) {
        if addLanguage {
            languageCodes.append(allLanguages[languagesPickerView.selectedRow(inComponent: 0)].code)
        }
        addLanguage = !addLanguage
        languagesPickerView.reloadAllComponents()
    }
    
    // MARK: - Delegates and datasource
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if addLanguage {

        } else {
            selectedLanguageCode = languageCodes[row]
        }
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if addLanguage {
            return allLanguages.count
        } else {
            return languageCodes.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if addLanguage {
            return allLanguages[row].name
        } else {
            let rowLanguageCode = languageCodes[row]
            if let validIndex = allLanguages.index(where: { (s: Language) -> Bool in
                s.code == rowLanguageCode
            }){
                return allLanguages[validIndex].name
            } else {
                return Constants.NoLanguage
            }
        }
    }

    // MARK: - ViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
                
        languagesPickerView.dataSource = self
        languagesPickerView.delegate = self
        
        // MARK: TBD - I should move the picker to the current language
        if let validCurrentLanguageCode = currentLanguageCode {
            let index = languageCodes.index(of: validCurrentLanguageCode)
            if let validIndex = index {
                languagesPickerView.selectRow(validIndex, inComponent: 0, animated: true)
            }         }
        
        title = NSLocalizedString("Select Language", comment: "Title of viewcontroller which allows the selecting of a product language.")
    }

}
