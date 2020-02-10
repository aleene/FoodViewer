//
//  SelectLanguageViewController.swift
//  FoodViewer
//
//  Created by arnaud on 03/09/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

protocol SelectLanguageViewControllerCoordinator {
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

final class SelectLanguageViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var coordinator: (Coordinator & SelectLanguageViewControllerCoordinator)? = nil
    // MARK: - External properties
    
    public func configure(primaryLanguageCode: String?, currentLanguageCode: String?, languageCodes: [String]?) {
        self.primaryLanguageCode = primaryLanguageCode
        self.currentLanguageCode = currentLanguageCode
        self.languageCodes = languageCodes
    }
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
    /*
    var editMode = false {
        didSet {
            setAddBarButtonItem()
        }
    }
     */
    
    //var productPair: ProductPair? = nil

    var sourcePage = 0

    // MARK: - Internal properties
    
    private var sortedLanguages: [Language] = []
    
    private var filteredLanguages: [Language] = []
    
    var textFilter: String = "" {
        didSet {
            filteredLanguages = textFilter.isEmpty ? sortedLanguages :
                sortedLanguages.filter({ $0.name.lowercased().contains(textFilter) })        }
    }
    
    // These are only the languageCodes that are not yet on the product
    private var languageCodesToUse: [String] {
        get {
            guard let validLanguageCodes = languageCodes else { return [] }
            return updatedLanguageCodes.count > validLanguageCodes.count ? updatedLanguageCodes : validLanguageCodes
        }
    }


    //  MARK : Interface elements

    @IBOutlet weak var languagesPickerView: UIPickerView! {
        didSet {
            languagesPickerView.dataSource = self
            languagesPickerView.delegate = self
        }
    }
    
    @IBOutlet weak var languageTextField: UITextField!
    
    @IBAction func defineLanguageTextField(_ sender: UITextField) {
        
    }
    
    @IBAction func cancelBarButtonItemTapped(_ sender: UIBarButtonItem) {
        coordinator?.selectLanguageViewController(self, selected:selectedLanguageCode)
    }
    
    @IBAction func doneBarButtonItemTapped(_ sender: UIBarButtonItem) {
    }
    
    // MARK: - Delegates and datasource
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedLanguageCode = filteredLanguages[row].code
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return filteredLanguages.isEmpty ? 1 : filteredLanguages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if filteredLanguages.isEmpty {
            return TranslatableStrings.NoLanguageDefined
        } else {
            return filteredLanguages[row].name
        }
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let myLabel = view == nil ? UILabel() : view as? UILabel
        
        var attributedRowText = NSMutableAttributedString()

        if filteredLanguages.isEmpty {
            attributedRowText = NSMutableAttributedString(string: TranslatableStrings.NoLanguageDefined)
        //} else if row == 0 {
        //    attributedRowText = NSMutableAttributedString(string: Constants.Select)
        } else {
            attributedRowText = NSMutableAttributedString(string: filteredLanguages[row].name)
        }

        myLabel?.textAlignment = .center

        // has the primary languageCode been updated?
        let currentLanguageCode = primaryLanguageCode
        if !filteredLanguages.isEmpty && row > 0 {
            // is this the primary language?
            if (filteredLanguages[row].code == currentLanguageCode) {
                attributedRowText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue, range: NSRange(location: 0, length: attributedRowText.length))
            } else {
                attributedRowText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: attributedRowText.length))
            }
        }
        
        attributedRowText.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Helvetica", size: 16.0)!, range: NSRange(location: 0 ,length:attributedRowText.length))
        myLabel!.attributedText = attributedRowText
        return myLabel!
    }
    
    private func positionPickerView() {
        if let validCurrentLanguageCode = selectedLanguageCode {
            if let validIndex = filteredLanguages.firstIndex(where: { (s: Language) -> Bool in
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
    
    @IBAction func addBarButtonItemTapped(_ sender: UIBarButtonItem) {
        // self.performSegue(withIdentifier: Storyboard.AddLanguageSegueIdentifier, sender: self)
    }
    
    @IBOutlet weak var navItem: UINavigationItem!

    
    private func setAddBarButtonItem() {
        if addBarButtonItem != nil {
            addBarButtonItem!.isEnabled = false
        }
    }
    
    // MARK: - Segue stuff
    
    /*@IBAction func unwindAddLanguageForCancel(_ segue:UIStoryboardSegue) {
        // reload with first language?
    }
    
    @IBAction func unwindAddLanguageForDone(_ segue:UIStoryboardSegue) {
        guard let vc = segue.source as? AddLanguageViewController else { return }
        guard let newLanguageCode = vc.selectedLanguageCode else { return }
        // the languageCodes have been edited, so with have now an updated product
        productPair?.update(addLanguageCode: newLanguageCode)
        if updatedLanguageCodes.isEmpty {
            updatedLanguageCodes = languageCodes
        }
        updatedLanguageCodes.append(newLanguageCode)
        
        // recreate the language list
        sortedLanguages = []
        setupLanguages()
        textFilter = ""
        languagesPickerView.reloadComponent(0)
        selectedLanguageCode = newLanguageCode
        positionPickerView()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case segueIdentifier(to: AddLanguageViewController.self):
                if let vc = segue.destination as? AddLanguageViewController {
                    vc.currentLanguageCodes = languageCodesToUse
                    // vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                }
            default: break
            }
        }
    }
 */
    
    @objc func textChanged(notification: Notification) {
        if let text = languageTextField.text {
            textFilter = text
            self.languagesPickerView.reloadAllComponents()
            selectedLanguageCode = filteredLanguages.first?.code
        }
    }

    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        languageTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textFilter = ""
        navItem.title = TranslatableStrings.Select
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.textChanged(notification:)),
            name: UITextField.textDidChangeNotification,
            object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        positionPickerView()

    }

    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
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
        if !languageCodesToUse.isEmpty {
            sortedLanguages = []
            let allLanguages: [Language] = OFFplists.manager.allLanguages
            for code in languageCodesToUse {
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


// MARK: - UITextFieldDelegate Functions

extension SelectLanguageViewController: UITextFieldDelegate {
    
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

