//
//  ConfirmProductTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 27/09/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import LocalAuthentication

class ConfirmProductTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    var selectedAddress : Address? = nil
    var selectedShop: String? = nil
    var selectedDate: Date? = nil
    var product: FoodProduct?
    
    fileprivate struct Storyboard {
        static let SegueIdentifier = "Unwind Confirm Product Segue"
    }


    // MARK: - Actions
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        // has a change been carried out?
        if selectedShop != nil || selectedDate != nil || selectedDate != nil {
            let update = OFFUpdate()
            UIApplication.shared.isNetworkActivityIndicatorVisible = true

            // TBD kan de queue stuff niet in OFFUpdate gedaan worden?
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
                let fetchResult = update.confirmProduct(product: self.product, expiryDate: self.selectedDate, shop: self.selectedShop, location:self.selectedAddress)
                DispatchQueue.main.async(execute: { () -> Void in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    switch fetchResult {
                    case .success:
                        // get the new product data
                        OFFProducts.manager.reload(self.product!)
                        // send notification of success, so feedback can be given
                        NotificationCenter.default.post(name: .ProductUpdateSucceeded, object:nil)
                        break
                    case .failure:
                        // send notification of failure, so feedback can be given
                        NotificationCenter.default.post(name: .ProductUpdateFailed, object:nil)
                        break
                    }
                })
            })
        }
        // Go back and let the queue do its work
        self.performSegue(withIdentifier: Storyboard.SegueIdentifier, sender: self)
    }
    
    // MARK: - Table view data source

    fileprivate struct Constants {
        static let ExpiryDateCellIdentifier = "Expiry Date Picker Cell"
        static let PurchaseLocationCellIdentifier = "Purchase Location Picker Cell"
        static let ExpiryDateHeaderTitle = NSLocalizedString("Expiry Date", comment: "Header for Tableview section with product expiry date")
        static let PurchaseLocationHeaderTitle = NSLocalizedString("Purchase Location", comment: "Header for Tableview section with product purchase location date")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        default:
            break
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ExpiryDateCellIdentifier, for: indexPath) as! ExpiryDatePickerTableViewCell
            cell.currentDate = product?.expirationDate
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.PurchaseLocationCellIdentifier, for: indexPath) as! PickerViewTableViewCell
            cell.purchaseLocationPickerView.delegate = self
            cell.purchaseLocationPickerView.dataSource = self
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return Constants.ExpiryDateHeaderTitle
        default:
            return Constants.PurchaseLocationHeaderTitle
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return CGFloat(162)
        default:
            return CGFloat(162)
        }
    }

    
    // MARK: - PickerView Datasource methods
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if FavoriteShopsDefaults.manager.list.count == 0 {
            return 1
        } else {
            return FavoriteShopsDefaults.manager.list.count + 1
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    // MARK: - PickerView delegate methods
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if FavoriteShopsDefaults.manager.list.count == 0 {
            return NSLocalizedString("No Favorites defined", comment: "String in pickerView if no purchase shops are defined")
        } else {
            switch row {
            case 0:
                return NSLocalizedString("Shop unknown", comment: "String in pickerView if the purchase shop is not known")
            default:
                return FavoriteShopsDefaults.manager.list[row - 1].0
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if FavoriteShopsDefaults.manager.list.count == 0 {
            // TBD segue to favorite shop definition vc
        } else {
        switch row {
            case 0:
                selectedShop = nil
                selectedAddress = nil
            default:
                selectedShop = FavoriteShopsDefaults.manager.list[row - 1].0
                selectedAddress = FavoriteShopsDefaults.manager.list[row - 1].1
            }
        }
    }
    

    /*  - Notification methods
    
    func expiryDateHasBeenUpdated(notification: Notification) -> Void {
        
        guard let userInfo = notification.userInfo,
            let message  = userInfo[ExpiryDatePickerTableViewCell.Notification.ExpiryDateHasBeenSetKey] as? Date else {
                print("No userInfo found in notification")
                return
        }

        selectedDate = notification.userInfo[ExpiryDatePickerTableViewCell.Notification.ExpiryDateHasBeenSetKey] as? Date
    }
    */
    private func authenticate() {
        
        // Is authentication necessary?
        // only for personal accounts and has not yet authenticated
        if OFFAccount().personalExists() && !Preferences.manager.userDidAuthenticate {
            // let the user ID himself with TouchID
            let context = LAContext()
            // The username and password will then be retrieved from the keychain if needed
            if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                    // the device knows TouchID
                context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Logging in with Touch ID", reply: {
                    (success: Bool, error: Error? ) -> Void in
                        
                    // 3. Inside the reply block, you handling the success case first. By default, the policy evaluation happens on a private thread, so your code jumps back to the main thread so it can update the UI. If the authentication was successful, you call the segue that dismisses the login view.
                        
                    // DispatchQueue.main.async(execute: {
                    if success {
                        Preferences.manager.userDidAuthenticate = true
                    } else {
                        self.askPassword()
                    }
                    // } )
                } )
            }
                
        }
        // The login stuff has been done for the duration of this app run
        // so we will not bother the user any more
        Preferences.manager.userDidAuthenticate = true
    }

    private var password: String? = nil

    private func askPassword() {
        
        let alertController = UIAlertController(title: NSLocalizedString("Specify password",
                                                                         comment: "Title in AlertViewController, which lets the user enter his username/password."),
                                                message: NSLocalizedString("Authentication with TouchID failed. Specify your password",
                                                                           comment: "Explanatory text in AlertViewController, which lets the user enter his username/password."),
                                                preferredStyle:.alert)
        let useFoodViewer = UIAlertAction(title: NSLocalizedString("Reset",
                                                                   comment: "String in button, to let the user indicate he wants to cancel username/password input."),
                                          style: .default)
        { action -> Void in
            // set the foodviewer selected index
            OFFAccount().removePersonal()
            Preferences.manager.userDidAuthenticate = false
        }
        
        let useMyOwn = UIAlertAction(title: NSLocalizedString("Done", comment: "String in button, to let the user indicate he is ready with username/password input."), style: .default)
        { action -> Void in
            // I should check the password here
            if let validString = self.password {
                Preferences.manager.userDidAuthenticate = OFFAccount().check(password: validString) ? true : false
            }
        }
        alertController.addTextField { textField -> Void in
            textField.tag = 0
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
                password = validText
            }
        default:
            break
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.isFirstResponder { textField.resignFirstResponder() }
        
        return true
    }

    // MARK: - ViewController lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: .ExpirydateHasBeenSet,
                                               object:nil, queue:OperationQueue.main) {
                                                notification in
                                                guard let userInfo = notification.userInfo,
                                                    let _  = userInfo[ExpiryDatePickerTableViewCell.Notification.ExpiryDateHasBeenSetKey] as? Date else { return }
                                                self.selectedDate = notification.userInfo?[ExpiryDatePickerTableViewCell.Notification.ExpiryDateHasBeenSetKey] as? Date
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if OFFAccount().personalExists() {
            // maybe the user has to authenticate himself before continuing
            authenticate()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }
    
}

// Definition:
    extension Notification.Name {
        static let ProductUpdateSucceeded = Notification.Name("Product Update Succeeded")
        static let ProductUpdateFailed = Notification.Name("Product Update Failed")
}


