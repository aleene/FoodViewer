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
    
    var languageCodes: [String] = [] {
        didSet {
            setupLanguages()
        }
    }
    
    var updatedLanguageCodes: [String] = [] {
        didSet {
            setupLanguages()
        }
    }

    var currentLanguageCode: String? = nil {
        didSet {
            selectedLanguageCode = currentLanguageCode
        }
    }
        
    var primaryLanguageCode: String? = nil
    
    // Seems no longer used/relevant. Changing primary language is now elsewhere
    var updatedPrimaryLanguageCode: String? = nil {
        didSet {
            // delegate?.updated(primaryLanguageCode: updatedPrimaryLanguageCode!)
        }
    }
    
    var selectedLanguageCode: String? = nil {
        didSet {
            positionPickerView()
        }
    }

    var editMode = false {
        didSet {
            setAddBarButtonItem()
        }
    }
    
    var delegate: ProductPageViewController? = nil

    var sourcePage = 0

    // MARK: - Internal properties
    
    private var sortedLanguages: [Language] = []

    fileprivate struct Constants {
        // static let Select = "---" // NSLocalizedString("Select", comment: "First element of a pickerView, where the user has to select a language.")
    }
    
    private var languageCodesToUse: [String] {
        get {
            return updatedLanguageCodes.count > languageCodes.count ? updatedLanguageCodes : languageCodes
        }
    }


    //  MARK : Interface elements

    @IBOutlet weak var languagesPickerView: UIPickerView! {
        didSet {
            languagesPickerView.dataSource = self
            languagesPickerView.delegate = self
        }
    }
    
    // MARK: - Delegates and datasource
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedLanguageCode = sortedLanguages[row].code
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sortedLanguages.isEmpty ? 1 : sortedLanguages.count
//        if sortedLanguages.isEmpty {
//            return 1
//        } else {
//            return sortedLanguages.count + 1
//        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if sortedLanguages.isEmpty {
            return TranslatableStrings.NoLanguage
        //} else if row == 0 {
        //    return  Constants.Select
        } else {
            return sortedLanguages[row].name
        }
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let myLabel = view == nil ? UILabel() : view as? UILabel
        
        var attributedRowText = NSMutableAttributedString()

        if sortedLanguages.isEmpty {
            attributedRowText = NSMutableAttributedString(string: TranslatableStrings.NoLanguage)
        //} else if row == 0 {
        //    attributedRowText = NSMutableAttributedString(string: Constants.Select)
        } else {
            attributedRowText = NSMutableAttributedString(string: sortedLanguages[row].name)
        }

        myLabel?.textAlignment = .center

        // has the primary languageCode been updated?
        let currentLanguageCode = updatedPrimaryLanguageCode != nil ? updatedPrimaryLanguageCode : primaryLanguageCode
        if !sortedLanguages.isEmpty && row > 0 {
            // is this the primary language?
            if (sortedLanguages[row].code == currentLanguageCode) {
                attributedRowText.addAttribute(NSForegroundColorAttributeName, value: UIColor.blue, range: NSRange(location: 0, length: attributedRowText.length))
            } else {
                attributedRowText.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSRange(location: 0, length: attributedRowText.length))
            }
        }
        
        attributedRowText.addAttribute(NSFontAttributeName, value: UIFont(name: "Helvetica", size: 16.0)!, range: NSRange(location: 0 ,length:attributedRowText.length))
        myLabel!.attributedText = attributedRowText
        return myLabel!
    }
    
    private func positionPickerView() {
        if let validCurrentLanguageCode = selectedLanguageCode {
            if let validIndex = sortedLanguages.index(where: { (s: Language) -> Bool in
                s.code == validCurrentLanguageCode
            }){
                languagesPickerView.selectRow(validIndex, inComponent: 0, animated: true)
            }
        }
    }

    @IBOutlet weak var addBarButtonItem: UIBarButtonItem! {
        didSet {
            setAddBarButtonItem()
        }
    }
    
    private func setAddBarButtonItem() {
        if addBarButtonItem != nil {
            addBarButtonItem!.isEnabled = editMode
        }
    }
    
    // MARK: - Segue stuff
    
    fileprivate struct Storyboard {
        static let AddLanguageSegueIdentifier = "Add Language ViewController Segue"
    }

    @IBAction func unwindAddLanguageForCancel(_ segue:UIStoryboardSegue) {
        // reload with first nutrient?
    }
    
    @IBAction func unwindAddLanguageForDone(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? AddLanguageViewController {
            if let newLanguageCode = vc.selectedLanguageCode {
                // the languageCodes have been edited, so with have now an updated product
                delegate?.update(addLanguageCode: newLanguageCode)
                if updatedLanguageCodes.isEmpty {
                    updatedLanguageCodes = languageCodes
                }
                updatedLanguageCodes.append(newLanguageCode)
                languagesPickerView.reloadComponent(0)
                selectedLanguageCode = newLanguageCode
                positionPickerView()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.AddLanguageSegueIdentifier:
                if let vc = segue.destination as? AddLanguageViewController {
                    vc.currentLanguageCodes = languageCodesToUse
                    vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                }
            default: break
            }
        }
    }

    // MARK: - ViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.title = TranslatableStrings.Select
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        positionPickerView()
    }

    private func setupLanguages() {
        buildLanguagesToUse()
        sortedLanguages = sortedLanguages.sorted(by: forward)
    }
    
    private func buildLanguagesToUse() {
        if !languageCodesToUse.isEmpty {
            sortedLanguages = []
            let allLanguages: [Language] = OFFplists.manager.allLanguages(Locale.preferredLanguages[0])
            for code in languageCodesToUse {
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
    
}


