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
            delegate?.updated(primaryLanguageCode: updatedPrimaryLanguageCode!)
        }
    }
    
    var selectedLanguageCode: String? = nil

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
        static let NoLanguage = NSLocalizedString("no language defined", comment: "Text for language of product, when there is no language defined.")
    }
    
    private var languageCodesToUse: [String] {
        get {
            return updatedLanguageCodes.count > languageCodes.count ? updatedLanguageCodes : languageCodes
        }
    }


    //  MARK : Interface elements

    @IBOutlet weak var navBar: UINavigationBar!
        /*{
        didSet {
            navBar.topItem?.title = NSLocalizedString("Main Language", comment: "Title of a navigationBar with the main language")
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        // use the selected language also as the primary language
        // if editMode {
        //    updatedPrimaryLanguageCode = sortedLanguages[row].code
        //    languagesPickerView.reloadComponent(0)
        // }
        selectedLanguageCode = sortedLanguages[row].code
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if sortedLanguages.isEmpty {
            return 1
        } else {
            return sortedLanguages.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if sortedLanguages.isEmpty {
            return Constants.NoLanguage
        } else {
            return sortedLanguages[row].name
        }
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let myLabel = view == nil ? UILabel() : view as? UILabel
        
        var attributedRowText = NSMutableAttributedString()

        if sortedLanguages.isEmpty {
            attributedRowText = NSMutableAttributedString(string: Constants.NoLanguage)
        } else {
            attributedRowText = NSMutableAttributedString(string: sortedLanguages[row].name)
        }

        myLabel?.textAlignment = .center

        // has the primary languageCode been updated?
        let currentLanguageCode = updatedPrimaryLanguageCode != nil ? updatedPrimaryLanguageCode : primaryLanguageCode
        if !sortedLanguages.isEmpty {
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
        if editMode {
            if let validCurrentLanguageCode = primaryLanguageCode {
                if let validIndex = sortedLanguages.index(where: { (s: Language) -> Bool in
                    s.code == validCurrentLanguageCode
                }){
                    languagesPickerView.selectRow(validIndex, inComponent: 0, animated: true)
                }
            }
        } else {
            if let validCurrentLanguageCode = currentLanguageCode {
                if let validIndex = sortedLanguages.index(where: { (s: Language) -> Bool in
                    s.code == validCurrentLanguageCode
                }){
                    languagesPickerView.selectRow(validIndex, inComponent: 0, animated: true)
                }
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
                    // are we in a popovercontroller?
                    // define the anchor point
                    /*
                    if let ppc = vc.popoverPresentationController {
                        // set the main language button as the anchor of the popOver
                        ppc.permittedArrowDirections = .right
                        var anchorFrame = vc.navBar.frame
                        // anchorFrame.origin.x += currentCell.frame.origin.x
                        // anchorFrame.origin.y += currentCell.frame.origin.y
                        ppc.sourceRect = bottomCenter(anchorFrame)
                        vc.preferredContentSize = vc.view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                        }
 */

                }
            default: break
            }
        }
    }
    
    private func bottomCenter(_ frame: CGRect) -> CGRect {
        var newFrame = frame
        newFrame.origin.y += frame.size.height * 1.5
        newFrame.origin.x += frame.size.width / 2
        newFrame.size.height = 1
        newFrame.size.width = 1
        return newFrame
    }


    // MARK: - ViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
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


