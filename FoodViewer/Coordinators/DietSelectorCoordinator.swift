//
//  DietSelectorCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 17/02/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

/**
This class coordinates the viewControllers initiated by `DietSelectorCoordinator`.
 
Variables:
 - `childCoordinators`: the other coordinators that are required in child viewControllers;
 - `viewController`: the `DietSelectorTableViewController` that is managed;
 
Functions:
  - `init(with:)` the initalisation method
    - Parameter :  `the DietSelectorTableViewController` that needs to be managed
 
Managed viewControllers:
 - `ShowDietTriggersTableViewController`: allows to show a diet in detail. No protocol is needed as the user gow back via the Back button
*/
final class DietSelectorCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var viewController: UIViewController? = nil
    
    weak var productPair: ProductPair? = nil
    
    private var coordinatorViewController: DietSelectorTableViewController? {
        self.viewController as? DietSelectorTableViewController
    }

    init(with viewController:UIViewController) {
        self.viewController = viewController
    }
    
    func showDietTriggers(diet index: Int?) {
        let childViewController = ShowDietTriggersTableViewController.instantiate()
        childViewController.coordinator = self
        childViewController.configure(diet: index)
        presentAsPush(childViewController)
    }
}


