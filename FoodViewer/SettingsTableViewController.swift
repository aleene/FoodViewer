  //
//  SettingsTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 10/03/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    fileprivate struct Storyboard {
        static let ReturnToProductSegueIdentifier = "Settings Done"
    }
    
    fileprivate struct Constants {
        static let ViewControllerTitle = NSLocalizedString("Settings", comment: "TableViewController title for the settings scene.")
    }

    var storedHistory = History() {
        didSet {
            enableClearHistoryButton()
        }
    }

    var mostRecentProduct = MostRecentProduct()

    fileprivate func enableClearHistoryButton() {
        if clearHistoryButton != nil {
            if storedHistory.barcodes.isEmpty {
                clearHistoryButton.isEnabled = false
            } else {
                clearHistoryButton.isEnabled = true
            }
        }
    }
    
    var historyHasBeenRemoved = false
    
    func refresh() {
        if saltOrSodiumOutlet != nil {
            switch Preferences.manager.showSaltOrSodium {
            case .salt:
                saltOrSodiumOutlet!.selectedSegmentIndex = 0
            case .sodium:
                saltOrSodiumOutlet!.selectedSegmentIndex = 1
            }
        }
            if jouleOrCaloriesOutlet != nil {
            switch Preferences.manager.showCaloriesOrJoule {
            case .joule:
                jouleOrCaloriesOutlet!.selectedSegmentIndex = 0
            case .calories:
                jouleOrCaloriesOutlet!.selectedSegmentIndex = 1
            }
        }
        if nutritionUnitOutlet != nil {
            switch Preferences.manager.showNutritionDataPerServingOrPerStandard {
            case .perStandard:
                nutritionUnitOutlet!.selectedSegmentIndex = 0
            case .perServing:
                nutritionUnitOutlet!.selectedSegmentIndex = 1
            case .perDailyValue:
                nutritionUnitOutlet!.selectedSegmentIndex = 2
            }
        }
        
        runInTestModeSwitch.isOn = Preferences.manager.runInTestMode
    }

    @IBAction func runInTestmodeSwitchTapped(_ sender: UISwitch) {
        Preferences.manager.runInTestMode = !Preferences.manager.runInTestMode
    }
    
    // MARK: - Outlet methods

    @IBOutlet weak var clearHistoryButton: UIButton! {
        didSet {
            enableClearHistoryButton()
        }
    }
    
    @IBOutlet weak var runInTestModeSwitch: UISwitch! {
        didSet {
            runInTestModeSwitch.isOn = Preferences.manager.runInTestMode
        }
    }
    
    @IBOutlet weak var saltOrSodiumOutlet: UISegmentedControl! {
        didSet {
            saltOrSodiumOutlet.setTitle(NSLocalizedString("Salt", comment: "Title of first segment in switch, which lets the user select between salt or sodium"), forSegmentAt: 0)
            saltOrSodiumOutlet.setTitle(NSLocalizedString("Sodium", comment: "Title of third segment in switch, which lets the user select between salt or sodium"), forSegmentAt: 1)
        }
    }
    
    @IBOutlet weak var jouleOrCaloriesOutlet: UISegmentedControl! {
        didSet {
            jouleOrCaloriesOutlet.setTitle(NSLocalizedString("Joule", comment: "Title of first segment in switch, which lets the user select between joule or calories"), forSegmentAt: 0)
            jouleOrCaloriesOutlet.setTitle(NSLocalizedString("Calories", comment: "Title of second segment in switch, which lets the user select between joule or calories"), forSegmentAt: 1)
        }
    }
    
    @IBOutlet weak var nutritionUnitOutlet: UISegmentedControl! {
        didSet {
            nutritionUnitOutlet.setTitle(NSLocalizedString("Per 100 mg/ml", comment: "Title of first segment in switch, which lets the user select between per standard unit (100 mg/ml or per serving"), forSegmentAt: 0)
            nutritionUnitOutlet.setTitle(NSLocalizedString("Per Serving", comment: "Title of second segment in switch, which lets the user select between per standard unit (100 mg/ml or per serving"), forSegmentAt: 1)
        }
    }

    
    // MARK: - Action methods
    
    @IBAction func jouleOrCaloriesSwitchTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            Preferences.manager.showCaloriesOrJoule = .joule
        case 1:
            Preferences.manager.showCaloriesOrJoule = .calories
        default:
            break
        }
    }

    @IBAction func clearProductHistoryTapped(_ sender: UIButton) {
        storedHistory.removeAll()
        mostRecentProduct.remove()
        historyHasBeenRemoved = true
        enableClearHistoryButton()
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: Storyboard.ReturnToProductSegueIdentifier, sender: self)

    }
    
    @IBAction func saltOrSodiumSwitchTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            Preferences.manager.showSaltOrSodium = .salt
        case 1:
            Preferences.manager.showSaltOrSodium = .sodium
        default:
            break
        }
    }
    
    @IBAction func nutritionUnitSwitchTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            Preferences.manager.showNutritionDataPerServingOrPerStandard = .perStandard
        case 1:
            Preferences.manager.showNutritionDataPerServingOrPerStandard = .perServing
        default:
            break
        }

    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return 3
        default:
            return 1
        }
    }
    
    @IBAction func unwindAllergenWarningForCancel(_ segue:UIStoryboardSegue) {
        if let _ = segue.source as? AllergenWarningsTableViewController {
            tableView.reloadData()
        }
    }
    
    @IBAction func allergenWarningSettingsDone(_ segue:UIStoryboardSegue) {
        if let _ = segue.source as? AllergenWarningsTableViewController {
            tableView.reloadData()
        }
    }
    
    @IBAction func favoriteShopsSettingsDone(_ segue:UIStoryboardSegue) {
        if let _ = segue.source as? FavoriteShopsTableViewController {
            tableView.reloadData()
        }
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()

        title = Constants.ViewControllerTitle
    }

}

