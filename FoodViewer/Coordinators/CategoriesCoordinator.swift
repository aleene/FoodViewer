//
//  CategoriesCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 08/02/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

final class CategoriesCoordinator: Coordinator {
    
    var childCoordinator: Coordinator?
    
    weak var parentCoordinator: Coordinator? = nil
    
    var childCoordinators: [Coordinator] = []
    
    var viewController: UIViewController? = nil
    
    weak var productPair: ProductPair? = nil
    
    private var coordinatorViewController: CategoriesTableViewController? {
        self.viewController as? CategoriesTableViewController
    }

    init(with coordinator: Coordinator?) {
        self.viewController = CategoriesTableViewController.instantiate()
        self.coordinatorViewController?.coordinator = self
        self.parentCoordinator = coordinator
    }

    init(with viewController:UIViewController) {
        self.viewController = viewController
    }
    
    func show() {
        // Done in the viewController?
    }

    func selectCategory() {
        let coordinator = SelectPairCoordinator.init(with:self,
                              original: productPair?.categoriesInterpreted?.list,
                              allPairs: OFFplists.manager.allCategories,
                              multipleSelectionIsAllowed: true,
                              showOriginalsAsSelected: true,
                              tag: 0,
                              assignedHeader: TranslatableStrings.SelectedCategories,
                              unAssignedHeader: TranslatableStrings.UnselectedCategories,
                              undefinedText: TranslatableStrings.NoCategoryDefined)
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

extension CategoriesCoordinator: SelectPairCoordinatorProtocol {
    
    func selectPairViewController(_ sender:SelectPairViewController, selected strings: [String]?, tag: Int) {
        if let validStrings = strings {
            productPair?.update(categories: validStrings)
        }
        sender.dismiss(animated: true, completion: nil)
    }

    func selectPairViewControllerDidCancel(_ sender:SelectPairViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
    
}

