//
//  ApplicationPreferencesTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 25/01/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import UIKit

class ApplicationPreferencesTableViewController: UITableViewController {

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
    @IBOutlet weak var allowContinuousScanLabel: UILabel! {
        didSet {
            allowContinuousScanLabel?.text = TranslatableStrings.AllowContinuousScan
        }
    }
    
    @IBOutlet weak var allowContinuousScanSwitch: UISwitch! {
        didSet {
            allowContinuousScanSwitch.isOn = Preferences.manager.allowContinuousScan
        }
    }
    
    @IBAction func allowContinuousScanSwitchChanged(_ sender: UISwitch) {
        Preferences.manager.allowContinuousScan = allowContinuousScanSwitch.isOn
    }
    
    @IBOutlet weak var clearHistoryButton: UIButton! {
        didSet {
            enableClearHistoryButton()
            clearHistoryButton.setTitle(TranslatableStrings.ClearHistory, for: .normal)
        }
    }
    
    @IBAction func clearHistoryButtonTapped(_ sender: UIButton) {
        storedHistory.removeAll()
        mostRecentProduct.removeForCurrentProductType()
        historyHasBeenRemoved = true
        enableClearHistoryButton()
    }
    
    private var currentProductType: ProductType {
        return Preferences.manager.showProductType
    }
    
    @IBOutlet weak var productTypeSegmentedControl: UISegmentedControl! {
        didSet {
            productTypeSegmentedControl.setTitle(TranslatableStrings.Food, forSegmentAt: 0)
            productTypeSegmentedControl.setTitle(TranslatableStrings.Beauty, forSegmentAt: 1)
            productTypeSegmentedControl.setTitle(TranslatableStrings.PetFood, forSegmentAt: 2)
            productTypeSegmentedControl.setTitle(TranslatableStrings.Product, forSegmentAt: 3)
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
    
    @IBOutlet weak var appVersionAndBuildLabel: UILabel! {
        didSet {
            var label = ""
            
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                label.append(version)
            }
            if let build = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String {
                label.append(" / " + build)
            }
            appVersionAndBuildLabel.text = label
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = TranslatableStrings.ApplicationPreferences
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return TranslatableStrings.ProductTypePreferences
        case 1:
            return TranslatableStrings.ClearHistory
        case 2:
            return TranslatableStrings.AppVersionAndBuild
        default:
            return nil
        }
    }
}
