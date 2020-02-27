  //
//  SettingsTableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 10/03/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class ProductPresentationSettingsTableViewController: UITableViewController {

    // The coordinator is owned by ProductPresentationSettingsCoordinator
    weak var coordinator: Coordinator? = nil

    fileprivate struct Constants {
        static let ViewControllerTitle = TranslatableStrings.Preferences
        static let AllergenSegue = "Show Allergen Segue"
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
                saltOrSodiumSegmentedControl.isEnabled = true
            default:
                saltOrSodiumSegmentedControl.isEnabled = false
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
                jouleOrCaloriesSegmentedControl.isEnabled = true
            default:
                jouleOrCaloriesSegmentedControl.isEnabled = false
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
                nutritionUnitSegmentedControl.isEnabled = true
            default:
                nutritionUnitSegmentedControl.isEnabled = false
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
    
    // MARK: - Show Negative Ingredient Detections Preference
    
    // OFF analyses the ingredients and categorises them into minerals, additives, etc.
    // The app shows positive detections.
    // This option determines whether also negative detections are shown
    
    @IBOutlet weak var negativeIngredientDetectionsSegmentedControl: UISegmentedControl! {
        didSet {
            negativeIngredientDetectionsSegmentedControl.setTitle(TranslatableStrings.NegativeIngredientDetectionsDoNotShow, forSegmentAt: 0)
            negativeIngredientDetectionsSegmentedControl.setTitle(TranslatableStrings.NegativeIngredientDetectionsShow, forSegmentAt: 1)
            if let validNegativeIngredientDetectionsShown = NegativeIngredientDetectionsDefaults.manager.negativeIngredientDetectionsShown {
                negativeIngredientDetectionsSegmentedControl?.selectedSegmentIndex = validNegativeIngredientDetectionsShown ? 1 : 0
            } else {
                // use do not show as a default
                NegativeIngredientDetectionsDefaults.manager.set(false)
                negativeIngredientDetectionsSegmentedControl?.selectedSegmentIndex = 0
            }
        }
    }
    
    @IBAction func negativeIngredientDetectionsSegmentedControlTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            NegativeIngredientDetectionsDefaults.manager.set(false)
        case 1:
            NegativeIngredientDetectionsDefaults.manager.set(true)
        default:
            break
        }
    }
    
    // MARK: - TableView Delegate Functions
    
    private struct Row {
        static let SaltOrSodiumPreference = 0
        static let EnergyUnitPreference = 1
        static let NutritionUnitPreference = 2
        static let NutritionTableFormatPreference = 3
        static let NegativeIngredientDetectionsPreference = 4
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case Row.SaltOrSodiumPreference:
            return TranslatableStrings.SaltOrSodiumPreference
        case Row.EnergyUnitPreference:
            return TranslatableStrings.EnergyUnitPreference
        case Row.NutritionUnitPreference:
            return TranslatableStrings.NutritionUnitPreference
        case Row.NutritionTableFormatPreference:
            return TranslatableStrings.NutritionTableFormatPreference
        case Row.NegativeIngredientDetectionsPreference:
            return TranslatableStrings.NegativeIngredientDetectionsPreference
        default:
            break
        }
        return nil
    }
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        
        refreshAll()
        
        title = Constants.ViewControllerTitle
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        coordinator?.viewControllerDidDisappear(self)
        super.viewDidDisappear(animated)
    }

}
