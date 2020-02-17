//
//  SettingsCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 17/02/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

/**
This class coordinates the viewControllers initiated by `SettingsTableViewController`.
 
Variables:
 - `childCoordinators`: the other coordinators that are required in child viewControllers;
 - `viewController`: the `SettingsTableViewController` that is managed;
 
Functions:
  - `init(with:)` the initalisation method
    - Parameter :  `the SettingsTableViewController` that needs to be managed
 
 - `showDiets`: shows a viewController with all possible diets, which can be selected.
*/
final class SettingsCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var viewController: UIViewController? = nil
    
    weak var productPair: ProductPair? = nil
    
    init(with viewController:UIViewController) {
        self.viewController = viewController
    }
    
    func showDiets() {
        let childViewController = DietSelectorTableViewController.instantiate()
        // This controller needs its own coordinator, as it will spawn other viewControllers
        childViewController.coordinator = DietSelectorCoordinator.init(with: childViewController)
        presentAsPush(childViewController)
    }
    
    func showAllergens() {
        let childViewController = AllergenWarningsTableViewController.instantiate()
        presentAsPush(childViewController)
    }
    
    func showProductPresentationSettings() {
        let childViewController = ProductPresentationSettingsTableViewController.instantiate()
        presentAsPush(childViewController)
    }
    
    func showOpenFoodFactsPreferences() {
        let childViewController = OpenFoodFactsPreferencesTableViewController.instantiate()
        presentAsPush(childViewController)
    }

    func showApplicationSettings() {
        let childViewController = ApplicationSettingsTableViewController.instantiate()
        presentAsPush(childViewController)
    }
}


