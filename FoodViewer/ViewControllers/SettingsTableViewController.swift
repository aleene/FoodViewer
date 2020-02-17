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

final class SettingsTableViewController: UITableViewController {

    var coordinator: SettingsCoordinator? = nil
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: UITableViewCell.self), for: indexPath)
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = TranslatableStrings.AlertPreferencesExtended
        case 1:
            cell.textLabel?.text = TranslatableStrings.SelectedDietsPreferencesExtended
        case 2:
            cell.textLabel?.text = TranslatableStrings.DisplayPreferencesExtended
        case 3:
            cell.textLabel?.text = TranslatableStrings.OpenFoodFactsPreferencesExtended
        case 4:
            cell.textLabel?.text = TranslatableStrings.ApplicationPreferencesExtended
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        switch indexPath.section {
        case 0:
            coordinator?.showAllergens()
        case 1:
            coordinator?.showDiets()
        case 2:
            coordinator?.showProductPresentationSettings()
        case 3:
            coordinator?.showOpenFoodFactsPreferences()
        case 4:
            coordinator?.showApplicationSettings()
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return TranslatableStrings.AlertPreferences
        case 1:
            return TranslatableStrings.SelectedDietsPreferences
        case 2:
            return TranslatableStrings.DisplayPreferences
        case 3:
            return TranslatableStrings.OpenFoodFactsPreferences
        case 4:
            return TranslatableStrings.ApplicationPreferences
        default:
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator = SettingsCoordinator.init(with: self)
        tableView.delegate = self

        title = TranslatableStrings.UserScene
        
    }
}
