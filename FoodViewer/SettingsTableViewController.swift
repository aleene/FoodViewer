  //
//  SettingsTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 10/03/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UITextFieldDelegate {

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
    }

    @IBOutlet weak var offAcountToUse: UISegmentedControl! {
        didSet {
            offAcountToUse.setTitle(NSLocalizedString("foodviewer", comment: "Title of first segment in switch, which indicates the foodviewer account will be used for edits"), forSegmentAt: 0)
            // is a personal userID available?
            if OFFAccount().personalExists() {
                offAcountToUse.setTitle(OFFAccount().userId, forSegmentAt: 1)
                offAcountToUse.selectedSegmentIndex = 1
            } else {
                offAcountToUse.setTitle(NSLocalizedString("Set Account", comment: "Title of second segment in switch, which  indicates the user can set another account"), forSegmentAt: 1)
                offAcountToUse.selectedSegmentIndex = 0
            }
        }
    }
    
    @IBAction func offAccountToUseSegmentedControlTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            // The user wants to use foodviewer
            // session unlock is no longer relevant
            Preferences.manager.userDidAuthenticate = false
            // delete the personal OFF Account credentials
            OFFAccount().removePersonal()
            offAcountToUse.setTitle(NSLocalizedString("Set Account", comment: "Title of second segment in switch, which  indicates the user can set another account"), forSegmentAt: 1)
        case 1:
            // The user has to define his credentials
            setUserNamePassword()
            Preferences.manager.userDidAuthenticate = true
        default:
            break
        }

    }
    
    // MARK: - Credential functions
    
    private var username: String? = nil {
        didSet {
            privateCredentialsHaveBeenSet()
        }
    }
    private var password: String? = nil {
        didSet {
            privateCredentialsHaveBeenSet()
        }
    }

    private var offAccount = OFFAccount()
    
    private func privateCredentialsHaveBeenSet() {
        // only write if both items have been set
        if username != nil && password != nil {
            offAccount.userId = username!
            offAccount.password = password!
            // once stored in the keychain, remove the items
            username = nil
            password = nil
            // the user has specified a username and password, so we no longer bother him
            Preferences.manager.userDidAuthenticate = true
        }
    }
    

    // Function to ask username/password and store it in the keychain
    private func setUserNamePassword() {
        
        let alertController = UIAlertController(title: NSLocalizedString("Personal Account",
                                                                         comment: "Title in AlertViewController, which lets the user enter his username/password."),
                                                message: NSLocalizedString("Specify your credentials for OFF?",
                                                                           comment: "Explanatory text in AlertViewController, which lets the user enter his username/password."),
                                                preferredStyle:.alert)
        let useFoodViewer = UIAlertAction(title: NSLocalizedString("Cancel",
                                                                   comment: "String in button, to let the user indicate he wants to cancel username/password input."),
                                          style: .default) { action -> Void in
                                            // set the foodviewer selected index
                                            self.offAcountToUse.selectedSegmentIndex = 0
        }
        
        let useMyOwn = UIAlertAction(title: NSLocalizedString("Done", comment: "String in button, to let the user indicate he is ready with username/password input."), style: .default)
        { action -> Void in
            // change the title of the segmented controller to the account the user just entered
            self.offAcountToUse.setTitle(OFFAccount().userId, forSegmentAt: 1)
            // alertController.view.resignFirstResponder()
            // all depends on other asynchronic processes
        }
        alertController.addTextField { textField -> Void in
            textField.tag = 0
            textField.placeholder = NSLocalizedString("Username", comment: "String in textField placeholder, to show that the user has to enter his username.")
            textField.delegate = self
        }
        alertController.addTextField { textField -> Void in
            textField.tag = 1
            textField.placeholder = NSLocalizedString("Password", comment: "String in textField placeholder, to show that the user has to enter his password")
            textField.delegate = self
        }
        
        alertController.addAction(useFoodViewer)
        alertController.addAction(useMyOwn)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - TextField stuff
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder { textField.resignFirstResponder() }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // username
        switch textField.tag {
        case 0:
            if let validText = textField.text {
                username = validText
            }
        // password
        default:
            if let validText = textField.text {
                password = validText
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.isFirstResponder { textField.resignFirstResponder() }
        
        return true
    }

    // MARK: - Outlet methods

    @IBOutlet weak var clearHistoryButton: UIButton! {
        didSet {
            enableClearHistoryButton()
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
        return 5
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

