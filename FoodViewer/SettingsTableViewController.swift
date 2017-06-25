  //
//  SettingsTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 10/03/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    fileprivate struct Constants {
        static let ViewControllerTitle = NSLocalizedString("Preferences", comment: "TableViewController title for the settings scene.")
        static let AllergenSegue = "Show Allergen Segue"
    }

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

    @IBOutlet weak var clearHistoryButton: UIButton! {
        didSet {
            enableClearHistoryButton()
            clearHistoryButton.setTitle(NSLocalizedString("Clear History", comment: "Title of a button, which removes all items in the product search history."), for: .normal)
        }
    }

    @IBAction func clearHistoryButtonTapped(_ sender: UIButton) {
        storedHistory.removeAll()
        mostRecentProduct.removeAll()
        historyHasBeenRemoved = true
        enableClearHistoryButton()
    }
    
    // MARK: - Salt Or Sodium Functions
    
    private func refreshAll() {
        refreshSaltOrSodium()
        refreshJouleOrCalories()
        refreshNutritionUnit()
    }
    
    private func refreshSaltOrSodium() {
        switch Preferences.manager.showSaltOrSodium {
        case .salt:
            saltOrSodiumSegmentedControl?.selectedSegmentIndex = 0
        case .sodium:
            saltOrSodiumSegmentedControl?.selectedSegmentIndex = 1
        }
    }

    @IBOutlet weak var saltOrSodiumSegmentedControl: UISegmentedControl! {
        didSet {
            saltOrSodiumSegmentedControl.setTitle(NSLocalizedString("Salt", comment: "Title of first segment in switch, which lets the user select between salt or sodium"), forSegmentAt: 0)
            saltOrSodiumSegmentedControl.setTitle(NSLocalizedString("Sodium", comment: "Title of third segment in switch, which lets the user select between salt or sodium"), forSegmentAt: 1)
            refreshSaltOrSodium()
        }
    }
    
    @IBAction func saltOrSodiumSegmentedControlTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            Preferences.manager.showSaltOrSodium = .salt
        case 1:
            Preferences.manager.showSaltOrSodium = .sodium
        default:
            break
        }
    }
    
    // MARK: - Joule or Calories Functions
    
    private func refreshJouleOrCalories() {
        switch Preferences.manager.showCaloriesOrJoule {
        case .joule:
            jouleOrCaloriesSegmentedControl?.selectedSegmentIndex = 0
        case .calories:
            jouleOrCaloriesSegmentedControl?.selectedSegmentIndex = 1
        }
    }

    @IBOutlet weak var jouleOrCaloriesSegmentedControl: UISegmentedControl! {
        didSet {
            jouleOrCaloriesSegmentedControl.setTitle(NSLocalizedString("Joule", comment: "Title of first segment in switch, which lets the user select between joule or calories"), forSegmentAt: 0)
            jouleOrCaloriesSegmentedControl.setTitle(NSLocalizedString("Calories", comment: "Title of second segment in switch, which lets the user select between joule or calories"), forSegmentAt: 1)
            refreshJouleOrCalories()
        }
    }
    
    @IBAction func jouleOrCaloriesSegmentedControlTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            Preferences.manager.showCaloriesOrJoule = .joule
        case 1:
            Preferences.manager.showCaloriesOrJoule = .calories
        default:
            break
        }
    }
    
    // MARK: - per 100 or per portion or per daily value
    
    @IBOutlet weak var nutritionUnitSegmentedControl: UISegmentedControl! {
        didSet {
            nutritionUnitSegmentedControl.setTitle(NSLocalizedString("100 mg/ml", comment: "Title of first segment in switch, which lets the user select between per standard unit (per 100 mg/ml / per serving / per daily value)"), forSegmentAt: 0)
            nutritionUnitSegmentedControl.setTitle(NSLocalizedString("Serving", comment: "Title of second segment in switch, which lets the user select between per standard unit (per 100 mg/ml / per serving / per daily value)"), forSegmentAt: 1)
            nutritionUnitSegmentedControl.setTitle(NSLocalizedString("Daily Value", comment: "Title of third segment in switch, which lets the user select between per daily value (per 100 mg/ml / per serving / per daily value)"), forSegmentAt: 2)
            refreshNutritionUnit()
        }
    }
    
    @IBAction func nutritionUnitSegmentedControlTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            Preferences.manager.showNutritionDataPerServingOrPerStandard = .perStandard
        case 1:
            Preferences.manager.showNutritionDataPerServingOrPerStandard = .perServing
        case 2:
            Preferences.manager.showNutritionDataPerServingOrPerStandard = .perDailyValue
        default:
            break
        }
    }
    
    private func refreshNutritionUnit() {
        if nutritionUnitSegmentedControl != nil {
            switch Preferences.manager.showNutritionDataPerServingOrPerStandard {
            case .perStandard:
                nutritionUnitSegmentedControl!.selectedSegmentIndex = 0
            case .perServing:
                nutritionUnitSegmentedControl!.selectedSegmentIndex = 1
            case .perDailyValue:
                nutritionUnitSegmentedControl!.selectedSegmentIndex = 2
            }
        }
    }

    // MARK: - OFF Account Functions
    
    fileprivate var username: String? = nil {
        didSet {
            privateCredentialsHaveBeenSet()
        }
    }
    fileprivate var password: String? = nil {
        didSet {
            privateCredentialsHaveBeenSet()
        }
    }
    
    private var offAccount = OFFAccount()

    @IBOutlet weak var offAccountSegmentedControl: UISegmentedControl! {
        didSet {
            offAccountSegmentedControl.setTitle(NSLocalizedString("foodviewer", comment: "Title of first segment in switch, which indicates the foodviewer account will be used for edits"), forSegmentAt: 0)
            // is a personal userID available?
            if OFFAccount().personalExists() {
                offAccountSegmentedControl.setTitle(OFFAccount().userId, forSegmentAt: 1)
                offAccountSegmentedControl.selectedSegmentIndex = 1
            } else {
                offAccountSegmentedControl.setTitle(NSLocalizedString("Set Account", comment: "Title of second segment in switch, which  indicates the user can set another account"), forSegmentAt: 1)
                offAccountSegmentedControl.selectedSegmentIndex = 0
            }
        }
    }
    @IBAction func offAccountSegmentedControlTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            // The user wants to use foodviewer
            // session unlock is no longer relevant
            Preferences.manager.userDidAuthenticate = false
            // delete the personal OFF Account credentials
            OFFAccount().removePersonal()
            offAccountSegmentedControl.setTitle(NSLocalizedString("Set Account", comment: "Title of second segment in switch, which  indicates the user can set another account"), forSegmentAt: 1)
        case 1:
            // The user has to define his credentials
            setUserNamePassword()
            Preferences.manager.userDidAuthenticate = true
        default:
            break
        }
    }
    
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
                                            self.offAccountSegmentedControl.selectedSegmentIndex = 0
        }
        
        let useMyOwn = UIAlertAction(title: NSLocalizedString("Done", comment: "String in button, to let the user indicate he is ready with username/password input."), style: .default)
        { action -> Void in
            // change the title of the segmented controller to the account the user just entered
            self.offAccountSegmentedControl.setTitle(OFFAccount().userId, forSegmentAt: 1)
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

    @IBAction func unwindAllergenWarningForCancel(_ segue:UIStoryboardSegue) {
        if let _ = segue.source as? AllergenWarningsTableViewController {
            tableView.reloadData()
        }
    }
    
    @IBAction func unwindAllergenWarningForDone(_ segue:UIStoryboardSegue) {
        if let _ = segue.source as? AllergenWarningsTableViewController {
            tableView.reloadData()
        }
    }

    
   
    // MARK: - TableView Delegate Functions
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 3:
            return NSLocalizedString("Reset", comment: "Title of a tableView section, which lets the user reset the history")
        case 0:
            return NSLocalizedString("Display Prefs", comment: "Title of a tableView section, which lets the user select display options")
        case 1:
            return NSLocalizedString("Warnings", comment: "Title of a tableView section, which lets the user set warnings")
        case 2:
            return NSLocalizedString("OpenFoodFacts Account", comment: "Title of a tableView section, which lets the user set the off account to use")
        default:
            break
        }
        return nil
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            performSegue(withIdentifier: Constants.AllergenSegue, sender: self)
        default:
            break
        }
    }

    // MARK: - ViewController Lifecycle
    
    override var prefersStatusBarHidden : Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        
        refreshAll()
        
        title = Constants.ViewControllerTitle
    }

}
  
// MARK: - UITextField Delegate Functions
  
extension SettingsTableViewController: UITextFieldDelegate {
    
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

  }
