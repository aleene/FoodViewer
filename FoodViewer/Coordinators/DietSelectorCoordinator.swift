//
//  DietSelectorCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 17/02/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

/**
This class coordinates the viewControllers initiated by `DietSelectorCoordinator` and their corresponding interaction flow.
 
 The interaction flow between the parent coordinator and this coordinator is handled by the parent coordinator through a extension. This interaction flow is defined as a protocol in the viewController coordinated by THIS class.
 
 - Important
 The parent coordinator must be passed on to the coordinated viewController and will be used for any protocol methods.

Variables:
 - `parentCoordinator`: the parent is the owner of this coordinator and the root for the associated viewController;
 - `childCoordinators`: the other coordinators that are required in child viewControllers;
 - `viewController`: the `DietSelectorTableViewController` that is managed;
 
Functions:
  - `init(with:)` the initalisation method of this coordinator AND the corresponding viewController.
    - Parameter :  the parent Coordinator;
 
 - `show()` - show the managed viewController from the parent viewController view stack. The viewController is push on a navigation controller.

 Managed viewControllers:
 - `ShowDietTriggersTableViewController`: allows to show a diet in detail. No protocol is needed as the user go back via the Back button
*/
final class DietSelectorCoordinator: Coordinator {
    
    weak var parentCoordinator: Coordinator? = nil

    var childCoordinators: [Coordinator] = []
    
    var viewController: UIViewController? = nil
        
    private var coordinatorViewController: DietSelectorTableViewController? {
        self.viewController as? DietSelectorTableViewController
    }

    init(with coordinator:Coordinator?) {
        self.viewController = DietSelectorTableViewController.instantiate()
        self.coordinatorViewController?.coordinator = self
        self.parentCoordinator = coordinator
    }

    func show() {
        if let parent = parentCoordinator as? SettingsCoordinator {
            parent.presentAsPush(viewController)
        }
    }
    
    func showDiet(with index: Int?) {
        let coordinator = ShowDietTriggersCoordinator.init(with: self, diet: index)
        childCoordinators.append(coordinator)
        coordinator.show()
    }
    
    func presentAsPush(_ viewController: UIViewController?) {
        guard let validViewController = viewController else { return }
        //viewController.modalPresentationStyle = .overFullScreen
        if let nav = self.viewController?.navigationController {
            nav.pushViewController(validViewController, animated: true)
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
