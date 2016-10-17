//
//  ConfirmProductTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 27/09/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class ConfirmProductTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {

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


