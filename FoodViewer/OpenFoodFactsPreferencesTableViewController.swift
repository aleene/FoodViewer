//
//  OpenFoodFactsPreferencesTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 25/01/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import UIKit

class OpenFoodFactsPreferencesTableViewController: UITableViewController {

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
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
    @IBAction func allowContinuousScanSwitched(_ sender: UISwitch) {
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
    
    @IBOutlet weak var createOffAccountButton: UIButton! {
        didSet {
            createOffAccountButton.setTitle(TranslatableStrings.CreateOffAccount, for: .normal)
        }
    }
    
    @IBAction func createOffAccountButtonTapped(_ sender: UIButton) {
        guard let url = URL(string: "https://world.openfoodfacts.org/cgi/user.pl") else { return }
        if #available(iOS 10.0, *) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            }
        } else {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = TranslatableStrings.OpenFoodFactsPreferences
    }
    
}


// MARK: - UITextField Delegate Functions

extension OpenFoodFactsPreferencesTableViewController: UITextFieldDelegate {
    
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
