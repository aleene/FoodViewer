//
//  UserTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 25/01/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//
//  The UserTableViewController handles everything specific to the user:
//  - alerts: allows the user to specify elements of a product that should draw his attention.
//              this can be a specific allergen, a trace, a specific ingredient or group of ingredients, etc.
//  - display prefs: allows the user to set up how he wants to see the product
//  - openFoodFacts: defines the user settings @ open food facts
//  - application

import UIKit

class UserTableViewController: UITableViewController {

    fileprivate struct Storyboard {
        fileprivate struct Segue {
            static let Alerts = "Show Alert Preferences Segue"
            static let DisplayPreferences = "Show Display Preferences Segue"
            static let OpenFoodFacts = "Show Open Food Facts Preferences Segue"
            static let Application = "Show Application Preferences Segue"
        }
        fileprivate struct CellIdentifier {
            static let Basic = "User Preferences TableViewCell Identifier"
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellIdentifier.Basic, for: indexPath)
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = TranslatableStrings.AlertPreferencesExtended
        case 1:
            cell.textLabel?.text = TranslatableStrings.DisplayPreferencesExtended
        case 2:
            cell.textLabel?.text = TranslatableStrings.OpenFoodFactsPreferencesExtended
        case 3:
            cell.textLabel?.text = TranslatableStrings.ApplicationPreferencesExtended
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            performSegue(withIdentifier: Storyboard.Segue.Alerts, sender: self)
        case 1:
            performSegue(withIdentifier: Storyboard.Segue.DisplayPreferences, sender: self)
        case 2:
            performSegue(withIdentifier: Storyboard.Segue.OpenFoodFacts, sender: self)
        case 3:
            performSegue(withIdentifier: Storyboard.Segue.Application, sender: self)
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return TranslatableStrings.AlertPreferences
        case 1:
            return TranslatableStrings.DisplayPreferences
        case 2:
            return TranslatableStrings.OpenFoodFactsPreferences
        case 3:
            return TranslatableStrings.ApplicationPreferences
        default:
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self

        title = TranslatableStrings.UserScene
        
    }
}
