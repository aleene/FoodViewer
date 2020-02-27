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
    
    weak var parentCoordinator: Coordinator? = nil
    
    private var coordinatorViewController: SettingsTableViewController? {
        self.viewController as? SettingsTableViewController
    }
    
    var childCoordinators: [Coordinator] = []
    
    var viewController: UIViewController? = nil
        
    init(with viewController:UIViewController) {
        self.viewController = viewController
        self.coordinatorViewController?.coordinator = self
    }
    
    init(with coordinator: Coordinator?) {
        // not used as the coordinator is inited from the viewController
    }

    
    // Not implementated. This is done in the Storyboard.
    func show() { }
    
    func presentAsPush(_ viewController: UIViewController?) {
        guard let validViewController = viewController else { return }
        //viewController.modalPresentationStyle = .overFullScreen
        if let nav = self.viewController?.navigationController {
            nav.pushViewController(validViewController, animated: true)
        }
    }

    func showAllergensSettings(_ sender: SettingsTableViewController) {
        let coordinator = AllergenWarningsCoordinator.init(with:self)
        self.childCoordinators.append(coordinator)
        coordinator.show()
    }
    
    func showDietSettings(_ sender: SettingsTableViewController) {
        let coordinator = DietSelectorCoordinator.init(with:self)
        self.childCoordinators.append(coordinator)
        coordinator.show()
    }
    
    func showProductPresentationSettings(_ sender: SettingsTableViewController) {
        let coordinator = ProductPresentationSettingsCoordinator.init(with:self)
        self.childCoordinators.append(coordinator)
        coordinator.show()
    }
    
    func showOpenFoodFactsSettings(_ sender: SettingsTableViewController) {
        let coordinator = OpenFoodFactsSettingsCoordinator.init(with:self)
        self.childCoordinators.append(coordinator)
        coordinator.show()
    }
    
    func showApplicationSettings(_ sender: SettingsTableViewController) {
        let coordinator = ApplicationSettingsCoordinator.init(with:self)
        self.childCoordinators.append(coordinator)
        coordinator.show()
    }
    
    /// The viewController informs its owner that it has disappeared
    func viewControllerDidDisappear(_ sender: UIViewController) {
        if childCoordinators.isEmpty {
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
