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
    
//  MARK : Interface elements
    
    @IBOutlet weak var languagesPickerView: UIPickerView! {
        didSet {
            languagesPickerView.dataSource = self
            languagesPickerView.delegate = self
        }
    }
    
    @IBOutlet weak var navItem: UINavigationItem!

// MARK: - Delegates and datasource
    
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedLanguageCode = row > 0 ? sortedLanguages[row - 1].code : nil
    }
    
    
    internal func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    internal func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return allLanguages.count + 1
    }
    
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if row == 0 {
            return "---"
        } else {
            return sortedLanguages[row - 1].name
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
        for code in currentLanguageCodes {
            if let validIndex = allLanguages.index(where: { (s: Language) -> Bool in
                s.code == code
            }){
                allLanguages.remove(at: validIndex)
            }
        }
    }

    // MARK: - ViewController Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navItem.title = TranslatableStrings.Select
    }
        
}


