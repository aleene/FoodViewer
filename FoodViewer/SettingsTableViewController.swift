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
        static let ViewControllerTitle = TranslatableStrings.Preferences
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
    

    @IBOutlet weak var foodOrBeautySgmentedControl: UISegmentedControl! {
        didSet {
            switch currentProductType {
            case .food:
                foodOrBeautySgmentedControl?.selectedSegmentIndex = 0
            case .beauty:
                foodOrBeautySgmentedControl?.selectedSegmentIndex = 1
            case .petFood:
                foodOrBeautySgmentedControl?.selectedSegmentIndex = 2

            }
        }
    }
    
    var changedCurrentProductType: ProductType = .food
    
    @IBAction func foodOrBeautySegmentedControlledTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            changedCurrentProductType = .food
        case 1:
            changedCurrentProductType = .beauty
        case 2:
            changedCurrentProductType = .petFood
        default:
            break
        }
    }
    
    @IBOutlet weak var nutritionFactsLabelStyleSegmentedControl: UISegmentedControl! {
        didSet {
            nutritionFactsLabelStyleSegmentedControl.setTitle(TranslatableStrings.ProductDefined, forSegmentAt: 0)
            nutritionFactsLabelStyleSegmentedControl.setTitle(TranslatableStrings.UserDefined, forSegmentAt: 1)
            
            switch Preferences.manager.nutritionFactsTableStyleSetter {
            case .product:
                nutritionFactsLabelStyleSegmentedControl?.selectedSegmentIndex = 0
            default:
                nutritionFactsLabelStyleSegmentedControl?.selectedSegmentIndex = 1
            }
        }
    }
    
    @IBAction func nutritionFactsLabelStyleSegmentedControlTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            Preferences.manager.nutritionFactsTableStyleSetter = .product
        case 1:
            Preferences.manager.nutritionFactsTableStyleSetter = .user
        default:
            break
        }
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
            saltOrSodiumSegmentedControl.setTitle(TranslatableStrings.Salt, forSegmentAt: 0)
            saltOrSodiumSegmentedControl.setTitle(TranslatableStrings.Sodium, forSegmentAt: 1)
            refreshSaltOrSodium()
            switch Preferences.manager.nutritionFactsTableStyleSetter {
            case .product:
                saltOrSodiumSegmentedControl.isEnabled = false
            default:
                saltOrSodiumSegmentedControl.isEnabled = true
            }
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
        case .kilocalorie:
            jouleOrCaloriesSegmentedControl?.selectedSegmentIndex = 1
        case .calories:
            jouleOrCaloriesSegmentedControl?.selectedSegmentIndex = 2
        }
    }

    @IBOutlet weak var jouleOrCaloriesSegmentedControl: UISegmentedControl! {
        didSet {
            jouleOrCaloriesSegmentedControl.setTitle(TranslatableStrings.Joule, forSegmentAt: 0)
            jouleOrCaloriesSegmentedControl.setTitle(TranslatableStrings.KiloCalorie, forSegmentAt: 1)
            jouleOrCaloriesSegmentedControl.setTitle(TranslatableStrings.Calories, forSegmentAt: 2)
            refreshJouleOrCalories()
            switch Preferences.manager.nutritionFactsTableStyleSetter {
            case .product:
                jouleOrCaloriesSegmentedControl.isEnabled = false
            default:
                jouleOrCaloriesSegmentedControl.isEnabled = true
            }

        }
    }
    
    @IBAction func jouleOrCaloriesSegmentedControlTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            Preferences.manager.showCaloriesOrJoule = .joule
        case 1:
            Preferences.manager.showCaloriesOrJoule = .kilocalorie
        case 2:
            Preferences.manager.showCaloriesOrJoule = .calories
        default:
            break
        }
    }
    
    // MARK: - per 100 or per portion or per daily value
    
    @IBOutlet weak var nutritionUnitSegmentedControl: UISegmentedControl! {
        didSet {
            nutritionUnitSegmentedControl.setTitle(TranslatableStrings.HunderdMgMl, forSegmentAt: 0)
            nutritionUnitSegmentedControl.setTitle(TranslatableStrings.Serving, forSegmentAt: 1)
            nutritionUnitSegmentedControl.setTitle(TranslatableStrings.DailyValue, forSegmentAt: 2)
            refreshNutritionUnit()
            switch Preferences.manager.nutritionFactsTableStyleSetter {
            case .product:
                nutritionUnitSegmentedControl.isEnabled = false
            default:
                nutritionUnitSegmentedControl.isEnabled = true
            }

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
            case .perStandard, .perThousandGram:
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
            offAccountSegmentedControl.setTitle((Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String), forSegmentAt: 0)
            // is a personal userID available?
            if OFFAccount().personalExists() {
                offAccountSegmentedControl.setTitle(OFFAccount().userId, forSegmentAt: 1)
                offAccountSegmentedControl.selectedSegmentIndex = 1
            } else {
                offAccountSegmentedControl.setTitle(TranslatableStrings.SetAccount, forSegmentAt: 1)
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
            offAccountSegmentedControl.setTitle(TranslatableStrings.SetAccount, forSegmentAt: 1)
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
        
        let alertController = UIAlertController(title: TranslatableStrings.PersonalAccount,
                                                message: TranslatableStrings.SpecifyYourCredentialsForOFF,
                                                preferredStyle:.alert)
        let useFoodViewer = UIAlertAction(title: TranslatableStrings.Cancel,
                                          style: .default) { action -> Void in
                                            // set the foodviewer selected index
                                            self.offAccountSegmentedControl.selectedSegmentIndex = 0
        }
        
        let useMyOwn = UIAlertAction(title: TranslatableStrings.Done, style: .default)
        { action -> Void in
            // change the title of the segmented controller to the account the user just entered
            self.offAccountSegmentedControl.setTitle(OFFAccount().userId, forSegmentAt: 1)
            // alertController.view.resignFirstResponder()
            // all depends on other asynchronic processes
        }
        alertController.addTextField { textField -> Void in
            textField.tag = 0
            textField.placeholder = TranslatableStrings.Username
            textField.delegate = self
        }
        alertController.addTextField { textField -> Void in
            textField.tag = 1
            textField.placeholder = TranslatableStrings.Password
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
            return TranslatableStrings.Reset
        case 0:
            return TranslatableStrings.DisplayPrefs
        case 1:
            return TranslatableStrings.Warnings
        case 2:
            return TranslatableStrings.OpenFoodFactsAccount
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
