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
        static let EnterShopnamePlaceholder = NSLocalizedString("Enter shop name", comment: "Placeholder text for field where user should enter a shop name.")
        static let EnterStreetnamePlaceholder = NSLocalizedString("Enter street name", comment: "Placeholder text for field where user should enter a street name.")
        static let EnterPostalcodePlaceholder = NSLocalizedString("Enter postal code", comment: "Placeholder text for field where user should enter a postal code.")
        static let EnterCitynamePlaceholder = NSLocalizedString("Enter city name", comment: "Placeholder text for field where user should enter a city name.")
        static let EnterCountrynamePlaceholder = NSLocalizedString("Enter country name", comment: "Placeholder text for field where user should enter a country name.")
        static let TableLength = 5
    }

    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        // Force edit end
        
        self.view.endEditing(true)
        self.performSegue(withIdentifier: Storyboard.SegueIdentifier, sender: self)
    }
    
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
            cell.textField.placeholder = Constants.EnterShopnamePlaceholder
        case 1:
            cell.textField.placeholder = Constants.EnterStreetnamePlaceholder
        case 2:
            cell.textField.placeholder = Constants.EnterPostalcodePlaceholder
        case 3:
            cell.textField.placeholder = Constants.EnterCitynamePlaceholder
        case 4:
            cell.textField.placeholder = Constants.EnterCountrynamePlaceholder
        // nothing happened
        default:
            break
        }

        return cell
    }
    
    /*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath)
        currentCell?.textLabel?.becomeFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath)
        currentCell?.textLabel?.resignFirstResponder()

    }
 */
    
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

}
