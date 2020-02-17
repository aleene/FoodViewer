//
//  ApplicationSettingsTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 25/01/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import UIKit

class ApplicationSettingsTableViewController: UITableViewController {

    // MARK: - Clear History functions
    
    var storedHistory = History() {
        didSet {
            enableClearHistoryButton()
        }
    }
    
    var historyHasBeenRemoved = false
    
    var mostRecentProduct = MostRecentProduct()
    
    fileprivate func enableClearHistoryButton() {
        if clearHistoryButton != nil {
            if storedHistory.barcodeTuples.isEmpty {
                clearHistoryButton.isEnabled = false
            } else {
                clearHistoryButton.isEnabled = true
            }
        }
    }
    
    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }
    
    // MARK: - Continuous Scan Preference
    
    // When scanning a product the application either switched to the product details or allows to scan the next product.
    
    @IBOutlet weak var continuousScanSegmentedControl: UISegmentedControl! {
        didSet {
            setContinuousScan()
        }
    }
    
    private func setContinuousScan() {
        continuousScanSegmentedControl?.isEnabled = true
        continuousScanSegmentedControl?.setTitle(TranslatableStrings.ContinuousScanDoNotAllow, forSegmentAt: 0)
        continuousScanSegmentedControl?.setTitle(TranslatableStrings.ContinuousScanAllow, forSegmentAt: 1)
        if let validAllowContinuousScan = ContinuousScanDefaults.manager.allowContinuousScan {
            continuousScanSegmentedControl?.selectedSegmentIndex = validAllowContinuousScan ? 1 : 0
        } else {
            // use do not show as a default
            ContinuousScanDefaults.manager.set(true)
            continuousScanSegmentedControl?.selectedSegmentIndex = 1
        }
    }
    
    @IBAction func continuousScanSegmentedControlTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            ContinuousScanDefaults.manager.set(false)
        case 1:
            ContinuousScanDefaults.manager.set(true)
        default:
            break
        }
    }
    
    // MARK: - Clear History Preference
    
    @IBOutlet weak var clearHistoryButton: UIButton! {
        didSet {
            setClearHistory()
        }
    }
    
    private func setClearHistory() {
        enableClearHistoryButton()
        clearHistoryButton?.setTitle(TranslatableStrings.ClearHistory, for: .normal)
    }
    
    @IBAction func clearHistoryButtonTapped(_ sender: UIButton) {
        storedHistory.removeAll()
        mostRecentProduct.removeForCurrentProductType()
        historyHasBeenRemoved = true
        enableClearHistoryButton()
    }
    
    // MARK: - Default Product Type Preference
    
    @IBOutlet weak var productTypeSegmentedControl: UISegmentedControl! {
        didSet {
            setProductType()
        }
    }
    
    private func setProductType() {
        productTypeSegmentedControl?.setTitle(TranslatableStrings.Food, forSegmentAt: 0)
        productTypeSegmentedControl?.setTitle(TranslatableStrings.Beauty, forSegmentAt: 1)
        productTypeSegmentedControl?.setTitle(TranslatableStrings.PetFood, forSegmentAt: 2)
        productTypeSegmentedControl?.setTitle(TranslatableStrings.Product, forSegmentAt: 3)
        switch currentProductType {
        case .food:
            productTypeSegmentedControl?.selectedSegmentIndex = 0
        case .beauty:
            productTypeSegmentedControl?.selectedSegmentIndex = 1
        case .petFood:
            productTypeSegmentedControl?.selectedSegmentIndex = 2
        case .product:
            productTypeSegmentedControl?.selectedSegmentIndex = 3
        }
    }
    
    var changedCurrentProductType: ProductType = .food
    
    @IBAction func productTypeSegmentedControlledTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            changedCurrentProductType = .food
        case 1:
            changedCurrentProductType = .beauty
        case 2:
            changedCurrentProductType = .petFood
        case 3:
            changedCurrentProductType = .product
        default:
            break
        }
    }
    
    // MARK: - View Toggle Mode
    
    // The user can toggle the view on several places:
    // - Cycle through product languages
    // - Switch between salt and sodium
    // - Switch between Joule and kcal
    // - Switch between edited and original
    // - Switch between UK nutritional score and France nutritional score
    // This setting allows the user to select between a double tap or a button for changing the view mode.
    
    @IBOutlet weak var viewToggleModeSegmentedControl: UISegmentedControl! {
        didSet {
            setViewToggleMode()
        }
    }
    
    private func setViewToggleMode() {
        viewToggleModeSegmentedControl?.setTitle(TranslatableStrings.ViewToggleModeButton, forSegmentAt: 1)
        viewToggleModeSegmentedControl?.setTitle(TranslatableStrings.ViewToggleModeDoubletap, forSegmentAt: 0)
        if let validButtonNotDoubleTap = ViewToggleModeDefaults.manager.buttonNotDoubleTap {
            viewToggleModeSegmentedControl?.selectedSegmentIndex = validButtonNotDoubleTap ? 1 : 0
        } else {
            ViewToggleModeDefaults.manager.set(ViewToggleModeDefaults.manager.buttonNotDoubleTapDefault)
            viewToggleModeSegmentedControl?.selectedSegmentIndex = ViewToggleModeDefaults.manager.buttonNotDoubleTapDefault ? 1 : 0
        }
    }
    
    @IBAction func viewToggleModeSegmentedControlTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            ViewToggleModeDefaults.manager.set(false)
        case 1:
            ViewToggleModeDefaults.manager.set(true)
        default:
            break
        }
    }
    
    // MARK: - Tag Entry Language

    // The user can enter tags for new products. If the user does not specify the language of the tag by prefacing the tag with a language code (fr: or nl:), then the system must make an assumption for the default. This defauly can be one of two languages:
    // - system language
    // - (main) product language
    
    @IBOutlet weak var tagEntryLanguageSegmentedControl: UISegmentedControl! {
        didSet {
            setTagEntryLanguage()
        }
    }
    
    private func setTagEntryLanguage() {
        tagEntryLanguageSegmentedControl?.setTitle(TranslatableStrings.TagEntryLanguageSystem, forSegmentAt: 0)
        tagEntryLanguageSegmentedControl?.setTitle(TranslatableStrings.TagEntryLanguageProduct, forSegmentAt: 1)
        if let validTagEntryLanguageProductNotSystem = TagEntryLanguageDefaults.manager.productLanguageNotSystemLanguage {
            tagEntryLanguageSegmentedControl?.selectedSegmentIndex = validTagEntryLanguageProductNotSystem ? 1 : 0
        } else {
            // use do not show as a default
            let tagEntryLanguageProductNotSystemDefault = true
            TagEntryLanguageDefaults.manager.set(tagEntryLanguageProductNotSystemDefault)
            tagEntryLanguageSegmentedControl?.selectedSegmentIndex = tagEntryLanguageProductNotSystemDefault ? 1 : 0
        }
    }
    
    @IBAction func tagEntryLanguageSegmentedControlTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
           TagEntryLanguageDefaults.manager.set(false)
        case 1:
            TagEntryLanguageDefaults.manager.set(true)
        default:
            break
        }
    }
    
    
    // MARK: - App Version and build
    
    @IBOutlet weak var appVersionAndBuildLabel: UILabel! {
        didSet {
            setAppVersionAndBuild()
        }
    }
    
    private func setAppVersionAndBuild() {
        var label = ""
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            label.append(version)
        }
        if let build = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String {
            label.append(" / " + build)
        }
        appVersionAndBuildLabel?.text = label

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = TranslatableStrings.ApplicationPreferences
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setAppVersionAndBuild()
        setTagEntryLanguage()
        setViewToggleMode()
        setProductType()
        setClearHistory()
        setContinuousScan()
    }
    
    // MARK: - Table view data source

    private struct Row {
        static let ContinuousScan = 0
        static let DefaultProductType = 1
        static let ViewToggleMode = 2
        static let TagEntryLanguage = 3
        static let ClearHistory = 4
        static let ApplicationVersion = 5
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case Row.ContinuousScan:
            return TranslatableStrings.ContinuousScanPreference
        case Row.DefaultProductType:
            return TranslatableStrings.ProductTypePreference
        case Row.ViewToggleMode:
            return TranslatableStrings.ViewToggleModePreference
        case Row.TagEntryLanguage:
            return TranslatableStrings.TagEntryLanguagePreference
        case Row.ClearHistory:
            return TranslatableStrings.ClearHistory
        case Row.ApplicationVersion:
            return TranslatableStrings.AppVersionAndBuild
        default:
            return nil
        }
    }
}
