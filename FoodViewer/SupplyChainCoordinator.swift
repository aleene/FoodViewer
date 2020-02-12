//
//  SupplyChainCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 07/02/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

class SupplyChainCoordinator: Coordinator {    
    var childCoordinators: [Coordinator] = []
    var viewController: UIViewController? = nil
    
    weak var productPair: ProductPair? = nil
    
    private var coordinatorViewController: SupplyChainTableViewController? {
        self.viewController as? SupplyChainTableViewController
    }

    init(with viewController:UIViewController) {
        self.viewController = viewController
    }
    
    func selectFavoriteShop() {
        let childViewController = FavoriteShopsViewController.instantiate()
        childViewController.coordinator = self
        let childCoordinator = FavoriteShopsCoordinator.init(with: childViewController)
        childCoordinators.append(childCoordinator)
        presentAsFormSheet(childViewController)
    }
    
    func selectExpirationDate(anchoredOn button:UIButton) {
        let childViewController = SelectExpirationDateViewController.instantiate()
        childViewController.coordinator = self
        if let validName = productPair?.localProduct?.expirationDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            childViewController.currentDate = validName
        } else if let validName = productPair?.remoteProduct?.expirationDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            childViewController.currentDate = validName
        } else {
            childViewController.currentDate = nil
        }
        presentAsPopOver(childViewController, at: button)
    }

    func selectCountry() {
        let childViewController = SelectPairViewController.instantiate()
        childViewController.coordinator = self
        childViewController.configure(original: productPair?.countriesInterpreted?.list,
                     allPairs: OFFplists.manager.allCountries,
                     multipleSelectionIsAllowed: true,
                     showOriginalsAsSelected: true,
                     assignedHeader: TranslatableStrings.SelectedCountries,
                     unAssignedHeader: TranslatableStrings.UnselectedCountries,
                     undefinedText: TranslatableStrings.NoCountryDefined)
        presentAsFormSheet(childViewController)
    }
}


extension SupplyChainCoordinator: FavoriteShopsViewControllerCoordinator {
    
    func favoriteShopsTableViewControllerAddFavoriteShop(_ sender: FavoriteShopsViewController) {
        // This viewController has its own coordinator
        if let coordinator = childCoordinators.first(where: ({ $0 is FavoriteShopsCoordinator }) ) as? FavoriteShopsCoordinator {
            coordinator.showAddFavoriteShopTableViewController()
        }
    }
    
    func favoriteShopsTableViewController(_ sender:FavoriteShopsViewController, selected shop:(String, Address)?) {
        productPair?.update(shop: shop)
        sender.dismiss(animated: true, completion: nil)
    }

    func favoriteShopsTableViewControllerDidCancel(_ sender:FavoriteShopsViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
    
}

extension SupplyChainCoordinator: SelectExpirationDateViewControllerCoordinator {
    
    func selectExpirationDateViewController(_ sender:SelectExpirationDateViewController, selected date:Date?) {
        productPair?.update(expirationDate: date)
        sender.dismiss(animated: true, completion: nil)
    }

    func selectExpirationDateViewControllerDidCancel(_ sender:SelectExpirationDateViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
    
}

extension SupplyChainCoordinator: SelectPairViewControllerCoordinator {
    
    func selectPairViewController(_ sender:SelectPairViewController, selected strings: [String]?) {
        productPair?.update(countries: strings)
        sender.dismiss(animated: true, completion: nil)
    }

    func selectPairViewControllerDidCancel(_ sender:SelectPairViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
    
}

