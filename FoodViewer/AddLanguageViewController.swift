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
    
    fileprivate struct Constants {
        static let NoLanguage = NSLocalizedString("none", comment: "Text for language of product, when there is no language defined.")
    }
    
    //  MARK : Interface elements
    
    @IBOutlet weak var navBar: UINavigationBar!
        /*{
        didSet {
            navBar.topItem?.title = NSLocalizedString("Add Language", comment: "Title of a navigationBar to add languages")
        }
    }
 */
    
    @IBOutlet weak var languagesPickerView: UIPickerView! {
        didSet {
            languagesPickerView.dataSource = self
            languagesPickerView.delegate = self
        }
    }
    
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
            return NSLocalizedString("Select", comment: "First element of a pickerView, where the user has to select a nutrient.")
        } else {
            return sortedLanguages[row - 1].name
        }
    }
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
}


