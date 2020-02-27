//
//  ShowDietTriggersCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 18/02/2020.
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
 
 - `showDietTriggers(diet index: Int?)`
Managed viewControllers:
 - `ShowDietTriggersTableViewController`: allows to show a diet in detail. No protocol is needed as the user go back via the Back button
*/
final class ShowDietTriggersCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    
    var parentCoordinator: Coordinator? = nil
        
    var viewController: UIViewController? = nil
            
    private var coordinatorViewController: ShowDietTriggersTableViewController? {
        self.viewController as? ShowDietTriggersTableViewController
    }
    
    init(with coordinator: Coordinator?) {
        self.parentCoordinator = coordinator
        self.viewController = ShowDietTriggersTableViewController.instantiate()
    }
    
    convenience init(with coordinator: Coordinator?, diet index: Int?) {
        self.init(with: coordinator)
        self.coordinatorViewController?.coordinator = self
        coordinatorViewController?.configure(diet: index)
    }
    
    func show() {
        if let parent = parentCoordinator as? DietSelectorCoordinator {
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
