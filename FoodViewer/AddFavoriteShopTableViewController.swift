//
//  AddFavoriteShopTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 24/09/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class AddFavoriteShopTableViewController: UITableViewController, UITextFieldDelegate {

    var shopName: String? = nil
    var shopAddress: Address? = nil
    
    fileprivate struct Storyboard {
        static let TextViewCellIdentifier = "TextFieldCell"
        static let SegueIdentifier = "Unwind Add Favorite Shop Segue"
    }

    fileprivate struct Constants {
        static let TableLength = 5
    }

    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        // Force edit end
        
        self.view.endEditing(true)
        self.performSegue(withIdentifier: Storyboard.SegueIdentifier, sender: self)
    }
    
    @IBOutlet weak var navItem: UINavigationItem!

// MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Constants.TableLength
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.TextViewCellIdentifier, for: indexPath) as! TextFieldTableViewCell

        cell.textField.tag = indexPath.row
        cell.textField.delegate = self
        switch indexPath.row {
        case 0:
            cell.textField.placeholder = TranslatableStrings.EnterShopName
        case 1:
            cell.textField.placeholder = TranslatableStrings.EnterStreetName
        case 2:
            cell.textField.placeholder = TranslatableStrings.EnterPostalCode
        case 3:
            cell.textField.placeholder = TranslatableStrings.EnterCityName
        case 4:
            cell.textField.placeholder = TranslatableStrings.EnterCountryName
        // nothing happened
        default:
            break
        }

        return cell
    }
    
    // MARK: - TextField stuff

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder { textField.resignFirstResponder() }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // print(textField.tag, textField.text)
        switch textField.tag {
        case 0:
            if let validText = textField.text {
                shopName = validText
            }
        case 1:
            if let validText = textField.text {
                if shopAddress == nil {
                    shopAddress = Address.init()
                }
                shopAddress?.street = validText
            }
        case 2:
            if let validText = textField.text {
                if shopAddress == nil {
                    shopAddress = Address.init()
                }
                shopAddress?.postalcode = validText
            }
        case 3:
            if let validText = textField.text {
                if shopAddress == nil {
                    shopAddress = Address.init()
                }
                shopAddress?.city = validText
            }
        case 4:
            if let validText = textField.text {
                if shopAddress == nil {
                    shopAddress = Address.init()
                }
                shopAddress?.country = validText
            }
            // nothing happened
        default:
            shopName = nil
            shopAddress = nil
        }
        /*
        let nextRow = textField.tag < Constants.TableLength - 1 ? textField.tag + 1 : 0
        
        let nextCell = tableView.cellForRow(at: IndexPath.init(row: nextRow, section: 0))
        
        nextCell?.textLabel?.becomeFirstResponder()
        */
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.isFirstResponder { textField.resignFirstResponder() }
        
        return true
    }
    
// MARK: - ViewController Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navItem.title = TranslatableStrings.Select
    }
    

}
