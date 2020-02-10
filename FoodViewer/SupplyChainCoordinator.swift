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
        let childViewController = FavoriteShopsTableViewController.instantiate()
        childViewController.coordinator = self
        let childCoordinator = FavoriteShopsCoordinator.init(with: childViewController)
        childCoordinators.append(childCoordinator)
        viewController?.present(childViewController, animated: true, completion: nil)
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
        childViewController.modalPresentationStyle = .popover
        if let ppc = childViewController.popoverPresentationController {
            // set the main language button as the anchor of the popOver
            ppc.permittedArrowDirections = .right
            // I need the button coordinates in the coordinates of the current controller view
            let anchorFrame = button.convert(button.bounds, to: self.viewController?.view)
            ppc.sourceRect = anchorFrame // bottomCenter(anchorFrame)
            ppc.sourceView = self.viewController?.view
            ppc.delegate = self.coordinatorViewController
            childViewController.preferredContentSize = childViewController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            viewController?.present(childViewController, animated: true, completion: nil)
        }
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
        viewController?.present(childViewController, animated: true, completion: nil)
    }
    
    private func refresh() {
        if let vc = self.viewController as? SupplyChainTableViewController {
            vc.refreshInterface()
        }
    }

}


extension SupplyChainCoordinator: FavoriteShopsTableViewControllerCoordinator {
    
    func favoriteShopsTableViewControllerAddFavoriteShop(_ sender: FavoriteShopsTableViewController) {
        // This viewController has its own coordinator
        if let coordinator = childCoordinators.first(where: ({ $0 is FavoriteShopsCoordinator }) ) as? FavoriteShopsCoordinator {
            coordinator.showAddFavoriteShopTableViewController()
        }
    }
    
    func favoriteShopsTableViewController(_ sender:FavoriteShopsTableViewController, selected shop:(String, Address)?) {
        if let validShop = shop {
            productPair?.update(shop: validShop)
            self.refresh()
        }
        sender.dismiss(animated: true, completion: nil)
    }

    func favoriteShopsTableViewControllerDidCancel(_ sender:FavoriteShopsTableViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
    
}

extension SupplyChainCoordinator: SelectExpirationDateViewControllerCoordinator {
    
    func selectExpirationDateViewController(_ sender:SelectExpirationDateViewController, selected date:Date?) {
        if let validDate = date {
            productPair?.update(expirationDate: validDate)
            self.refresh()
        }
        sender.dismiss(animated: true, completion: nil)
    }

    func selectExpirationDateViewControllerDidCancel(_ sender:SelectExpirationDateViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
    
}

extension SupplyChainCoordinator: SelectPairViewControllerCoordinator {
    
    func selectPairViewController(_ sender:SelectPairViewController, selected strings: [String]?) {
        productPair?.update(countries: strings)
        self.refresh()
        sender.dismiss(animated: true, completion: nil)
    }

    func selectPairViewControllerDidCancel(_ sender:SelectPairViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
    
}

