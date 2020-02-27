//
//  OpenFoodFactsSettingsCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 18/02/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

/**
This class coordinates the viewControllers initiated by `OpenFoodFactsSettingsCoordinator`.
 
Variables:
 - `childCoordinators`: the other coordinators that are required in child viewControllers;
 - `viewController`: the `OpenFoodFactsPreferencesTableViewController` that is managed;
 
Functions:
  - `init(with:)` the initalisation method
    - Parameter :  `the DietSelectorTableViewController` that needs to be managed
 
 - `showDietTriggers(diet index: Int?)`
Managed viewControllers:
 - `OpenFoodFactsPreferencesTableViewController`: allows to show a diet in detail. No protocol is needed as the user go back via the Back button
*/
final class OpenFoodFactsSettingsCoordinator: Coordinator {
    
    weak var parentCoordinator: Coordinator? = nil

    var childCoordinators: [Coordinator] = []
        
    var viewController: UIViewController? = nil
    
    private var coordinatorViewController: OpenFoodFactsPreferencesTableViewController? {
        self.viewController as? OpenFoodFactsPreferencesTableViewController
    }
    
    init(with coordinator:Coordinator?) {
        self.viewController = OpenFoodFactsPreferencesTableViewController.instantiate()
        coordinatorViewController?.coordinator = self
        self.parentCoordinator = coordinator
    }

    func show() {
        if let parent = parentCoordinator as? SettingsCoordinator {
            parent.presentAsPush(viewController)
        }
    }
    
    /// The viewController informs its owner that it has disappeared
    func viewControllerDidDisappear(_ sender: UIViewController) {
        if self.childCoordinators.isEmpty {
            self.viewController = nil
            informParent()
        }
    }
    
    /// A child coordinator informs its owner that it has disappeared
    func canDisappear(_ coordinator: Coordinator) {
        if let index = self.childCoordinators.lastIndex(where: ({ $0 === coordinator }) ) {
            self.childCoordinators.remove(at: index)
            informParent()
        }
    }
    
    private func informParent() {
        if self.childCoordinators.isEmpty
            && self.viewController == nil {
            parentCoordinator?.canDisappear(self)
        }
    }
}
