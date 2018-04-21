//
//  SelectLanguageAndImageTypeViewController.swift
//  FoodViewer
//
//  Created by arnaud on 04/11/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

class SelectLanguageAndImageTypeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    // MARK: - External properties
    
    var selectedImageCategory: ImageTypeCategory? = nil
    
    var languageCodes: [String] = [] {
        didSet {
            // automatically select the only available languageCode
            if languageCodes.count == 1 {
                selectedLanguageCode = languageCodes[0]
            }
            setupLanguages()
        }
    }

    
    var selectedLanguageCode: String? = nil
    
    var key: String? = nil
    
    //  MARK : Interface elements
    
    @IBOutlet weak var pickerView: UIPickerView! {
        didSet {
            pickerView.dataSource = self
            pickerView.delegate = self
        }
    }
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    private var sortedLanguages: [Language] = []
    
    // MARK: - Delegates and datasource
    
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 { // image type
            selectedImageCategory = row > 0 ? ImageTypeCategory.list[row - 1] : nil
        } else if component == 1 { // language
            selectedLanguageCode = row > 0 ? sortedLanguages[row - 1].code : languageCodes[0]
        }
    }
    
    internal func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    internal func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return ImageTypeCategory.list.count + 1
        } else if component == 1 {
            return languageCodes.count == 1 ? languageCodes.count : languageCodes.count + 1
        }
        return 0
    }
    
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if row == 0 {
            if component == 1 && languageCodes.count == 1 {
                return sortedLanguages[0].name
            }
            return "---"
        } else {
            if component == 0 {
                return ImageTypeCategory.list[row - 1].description
            } else if component == 1 {
                return sortedLanguages[row - 1].name
            }
        }
        return nil
    }
    
    // MARK: - Languages
    
    private func setupLanguages() {
        buildLanguagesToUse()
        sortedLanguages = sortedLanguages.sorted(by: forward)
    }
    
    private func buildLanguagesToUse() {
        if !languageCodes.isEmpty {
            sortedLanguages = []
            let allLanguages: [Language] = OFFplists.manager.allLanguages(Locale.preferredLanguages[0])
            for code in languageCodes {
                if let validIndex = allLanguages.index(where: { (s: Language) -> Bool in
                    s.code == code
                }){
                    sortedLanguages.append(allLanguages[validIndex])
                }
            }
        }
    }
    
    private func forward(_ s1: Language, _ s2: Language) -> Bool {
        return s1.name < s2.name
    }
    
    // MARK: - ViewController Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navItem.title = TranslatableStrings.AssignImage
    }
}
