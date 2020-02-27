//
//  AddFavoriteShopTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 24/09/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

protocol AddFavoriteShopCoordinatorProtocol {
    
/**
The done button has been tapped and a new shop has been created.
- Parameters:
 - sender: the `AddFavoriteShopTableViewController` that sent the message
 - shopName: The name of the added shop
 - shopAddress: The address of the added shop
*/
    func addFavoriteShopTableViewController(_ sender:AddFavoriteShopTableViewController, shopName: String?, shopAddress: Address?)
    
/**
The cancel button has been tapped and no new shop has been created.
     
- Parameters :
 - sender: the `AddFavoriteShopTableViewController` that sent the message
*/
    func addFavoriteShopTableViewControllerDidCancel(_ sender:AddFavoriteShopTableViewController)
    
    //func viewControllerDidDisappear(_ sender:UIViewController)
}

final class AddFavoriteShopTableViewController: UITableViewController {

    var protocolCoordinator: AddFavoriteShopCoordinatorProtocol? = nil
    
    weak var coordinator: Coordinator? = nil
    
    private var shopName: String? = nil
    private var shopAddress: Address? = nil
    
    fileprivate struct Storyboard {
        static let TextViewCellIdentifier = "TextFieldCell"
    }

    fileprivate struct Constants {
        static let TableLength = 5
    }

    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        // Force edit end
        
        self.view.endEditing(true)
        //self.performSegue(withIdentifier: StoryboardString.SegueIdentifier.FromAddFavoriteShopTableVC.UnwindVC, sender: self)
        protocolCoordinator?.addFavoriteShopTableViewController(self, shopName: shopName, shopAddress: shopAddress)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        protocolCoordinator?.addFavoriteShopTableViewControllerDidCancel(self)
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
    
// MARK: - ViewController Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navItem.title = TranslatableStrings.Select
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        coordinator?.viewControllerDidDisappear(self)
        super.viewDidDisappear(animated)
    }
}
//
// MARK: - UITextFieldDelegate functions
//
extension AddFavoriteShopTableViewController : UITextFieldDelegate {
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
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.isFirstResponder { textField.resignFirstResponder() }
        
        return true
    }

}
