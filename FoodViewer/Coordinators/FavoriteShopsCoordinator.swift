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
class FavoriteShopsCoordinator: Coordinator {    
    var childCoordinators: [Coordinator] = []
    var viewController: UIViewController? = nil
    
    private var coordinatorViewController: FavoriteShopsTableViewController? {
        self.viewController as? FavoriteShopsTableViewController
    }

    init(with viewController:UIViewController) {
        self.viewController = viewController
    }
    
    func showAddFavoriteShopTableViewController() {
        let childViewController = AddFavoriteShopTableViewController.instantiate()
        childViewController.coordinator = self
        viewController?.present(childViewController, animated: true, completion: nil)
    }
}


extension FavoriteShopsCoordinator: AddFavoriteShopTableViewControllerCoordinator {
    
    func addFavoriteShopTableViewController(_ viewController: AddFavoriteShopTableViewController, shopName: String?, shopAddress: Address?) {
         guard shopName != nil
                || shopAddress != nil else { return }
            
        // add to the list of favorite shops
        FavoriteShopsDefaults.manager.addShop(newShop: (shopName,
                                                        shopAddress))
        coordinatorViewController?.refresh()
    }
    
    func addFavoriteShopTableViewControllerDidCancel(_ viewController: AddFavoriteShopTableViewController) {
    }
}
