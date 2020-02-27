//
//  SelectLanguageViewController.swift
//  FoodViewer
//
//  Created by arnaud on 03/09/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

protocol SelectLanguageCoordinatorProtocol {
    /**
    Inform the protocol delegate that no shop has been selected.
    - Parameters:
         - sender : the `SelectLanguageViewController` that called the function.
         - languageCodes : the name and address of the selected languageCodes
    */
    func selectLanguageViewController(_ sender:SelectLanguageViewController, selected languageCode:String?)
    /**
    Inform the protocol delegate that no shop has been selected.
    - Parameters:
         - sender : the `SelectLanguageViewController` that called the function.
    */
    func selectLanguageViewControllerDidCancel(_ sender:SelectLanguageViewController)
}

/**
Shows a list of languageCodes in a pickerView and allows the user to select an entry

**Public variable**
 - `coordinator` : the coordinator of this viewController
 
**Public function**
- `configure(primaryLanguageCode: String?, currentLanguageCode: String?, languageCodes: [String]?)`: configures the viewController with the languageCodes.
- parameters:
  - primaryLanguageCode: the languageCode that needs to emphasized;
  - currentLanguageCode: the languageCode that will be selected in the pickerView;
  - languageCodes: an array of languageCodes that can be picked upon. This list includes the primaryLanguageCode and currentLanguageCode;
 */
final class SelectLanguageViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
//
// MARK: - External properties
//
    var protocolCoordinator: SelectLanguageCoordinatorProtocol? = nil
    
    /// The manager of this viewController and its protocol delegate
    weak var coordinator: Coordinator? = nil
//
// MARK: - External functions
//
/**
Configures the viewController with the languageCodes.
 - parameters:
   -  primaryLanguageCode: the languageCode that needs to emphasized;
   - currentLanguageCode: the languageCode that will be selected in the pickerView;
   - languageCodes : an array of languageCodes that can be picked upon. This list includes the primaryLanguageCode and currentLanguageCode;
*/
     public func configure(primaryLanguageCode: String?, currentLanguageCode: String?, languageCodes: [String]?) {
        self.primaryLanguageCode = primaryLanguageCode
        self.currentLanguageCode = currentLanguageCode
        self.languageCodes = languageCodes
    }
//
// MARK: - Internal properties
//
    private var languageCodes: [String]? = nil {
        didSet {
            setupLanguages()
        }
    }
    
    private var updatedLanguageCodes: [String] = [] {
        didSet {
            setupLanguages()
        }
     }

    private var currentLanguageCode: String? = nil {
        didSet {
            selectedLanguageCode = currentLanguageCode
        }
    }
        
    private var primaryLanguageCode: String? = nil
    
    private var selectedLanguageCode: String? = nil {
        didSet {
            positionPickerView()
        }
    }
    
    private var sortedLanguages: [Language] = []
//
//  MARK : Interface elements
//
    @IBOutlet weak var languagesPickerView: UIPickerView! {
        didSet {
            languagesPickerView.dataSource = self
            languagesPickerView.delegate = self
        }
    }
    
    @IBAction func cancelBarButtonItemTapped(_ sender: UIBarButtonItem) {
        protocolCoordinator?.selectLanguageViewControllerDidCancel(self)
    }
    
    @IBAction func doneBarButtonItemTapped(_ sender: UIBarButtonItem) {
        protocolCoordinator?.selectLanguageViewController(self, selected:selectedLanguageCode)
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
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if sortedLanguages.isEmpty {
            return TranslatableStrings.NoLanguageDefined
        } else {
            return sortedLanguages[row].name
        }
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let myLabel = view == nil ? UILabel() : view as? UILabel
        
        var attributedRowText = NSMutableAttributedString()

        if sortedLanguages.isEmpty {
            attributedRowText = NSMutableAttributedString(string: TranslatableStrings.NoLanguageDefined)
        //} else if row == 0 {
        //    attributedRowText = NSMutableAttributedString(string: Constants.Select)
        } else {
            attributedRowText = NSMutableAttributedString(string: sortedLanguages[row].name)
        }

        myLabel?.textAlignment = .center

        // has the primary languageCode been updated?
        let currentLanguageCode = primaryLanguageCode
        if !sortedLanguages.isEmpty && row > 0 {
            // is this the primary language?
            if sortedLanguages[row].code == currentLanguageCode {
                attributedRowText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.green, range: NSRange(location: 0, length: attributedRowText.length))
            } else {
                if #available(iOS 13.0, *) {
                    attributedRowText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.secondaryLabel, range: NSRange(location: 0, length: attributedRowText.length))
                } else {
                    attributedRowText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: attributedRowText.length))
                }
            }
        }
        
        attributedRowText.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Helvetica", size: 16.0)!, range: NSRange(location: 0 ,length:attributedRowText.length))
        myLabel!.attributedText = attributedRowText
        return myLabel!
    }
    
    private func positionPickerView() {
        if let validCurrentLanguageCode = selectedLanguageCode {
            if let validIndex = sortedLanguages.firstIndex(where: { (s: Language) -> Bool in
                s.code == validCurrentLanguageCode
            }){
                languagesPickerView.selectRow(validIndex, inComponent: 0, animated: true)
            }
        }
    }
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navItem.title = TranslatableStrings.Select
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        positionPickerView()

    }

    override func viewDidDisappear(_ animated: Bool) {
        coordinator?.viewControllerDidDisappear(self)
        super.viewDidDisappear(animated)
    }

    private func setupLanguages() {
        if sortedLanguages.isEmpty {
            buildLanguagesToUse()
            sortedLanguages = sortedLanguages.sorted(by: forward)
        }
    }
    
    private func buildLanguagesToUse() {
        sortedLanguages = []
        if let validLanguageCodes = languageCodes,
            !validLanguageCodes.isEmpty {
            let allLanguages: [Language] = OFFplists.manager.allLanguages
            for code in validLanguageCodes {
                if let validIndex = allLanguages.firstIndex(where: { (s: Language) -> Bool in
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
