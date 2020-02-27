//
//  AddFavoriteShopCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 07/02/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

/**
This class coordinates the viewControllers initiated by `FavoriteShopsCoordinator`.
 
Variables:
 - `childCoordinators`: the other coordinators that are required in child viewControllers;
 - `viewController`: the main viewController that is managed;
 
Functions:
  - `init(with:)` the initalisation method
    - Parameter :  viewController that needs to be managed
 
Managed viewControllers:
 - `AddFavoriteShopTableViewController`: allows to add a new shop to the list of favorite shops. Any flow is managed by this Coordinator through the `AddFavoriteShopTableViewControllerCoordinator` protocol.
*/
final class FavoriteShopsCoordinator: Coordinator {
    
    var childCoordinator: Coordinator?
    
    var parentCoordinator: Coordinator? = nil

    var childCoordinators: [Coordinator] = []

    var viewController: UIViewController? = nil

    private var coordinatorViewController: FavoriteShopsViewController? {
        self.viewController as? FavoriteShopsViewController
    }

    init(with coordinator: Coordinator?) {
        self.viewController = FavoriteShopsViewController.instantiate()
        self.parentCoordinator = coordinator
        self.coordinatorViewController?.coordinator = self
        if let protocolCoordinator = coordinator as? FavoriteShopsCoordinatorProtocol {
            self.coordinatorViewController?.protocolCoordinator = protocolCoordinator
        } else {
            print("FavoriteShopsCoordinator: coordinator does not conform to protocol")
        }
    }
    
    func show() {
        self.parentCoordinator?.presentAsFormSheet(self.viewController)
    }

    func showAddFavoriteShopTableViewController() {
        let coordinator = AddFavoriteShopCoordinator(with: self)
        childCoordinators.append(coordinator)
        coordinator.show()
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

extension FavoriteShopsCoordinator: AddFavoriteShopCoordinatorProtocol {
    
    func addFavoriteShopTableViewController(_ sender: AddFavoriteShopTableViewController, shopName: String?, shopAddress: Address?) {
        sender.dismiss(animated: true, completion: nil)
        if shopName != nil
                || shopAddress != nil {
            // add to the list of favorite shops
            FavoriteShopsDefaults.manager.addShop(newShop: (shopName,
                                                        shopAddress))
            coordinatorViewController?.refresh()
        }
    }
    
    func addFavoriteShopTableViewControllerDidCancel(_ sender: AddFavoriteShopTableViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
}
