//
//  CategoriesCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 08/02/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

class CategoriesCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var viewController: UIViewController? = nil
    
    weak var productPair: ProductPair? = nil
    
    init(with viewController:UIViewController) {
        self.viewController = viewController
    }
    
    func selectCategory() {
        let childViewController = SelectPairViewController.instantiate()
        childViewController.coordinator = self
        childViewController.configure(original: productPair?.categoriesInterpreted?.list,
                     allPairs: OFFplists.manager.allCategories,
                     multipleSelectionIsAllowed: true,
                     showOriginalsAsSelected: true,
                     assignedHeader: TranslatableStrings.SelectedCategories,
                     unAssignedHeader: TranslatableStrings.UnselectedCategories,
                     undefinedText: TranslatableStrings.NoCategoryDefined)
        presentAsFormSheet(childViewController)
    }
}

extension CategoriesCoordinator: SelectPairViewControllerCoordinator {
    
    func selectPairViewController(_ sender:SelectPairViewController, selected strings: [String]?) {
        if let validStrings = strings {
            productPair?.update(categories: validStrings)
        }
        sender.dismiss(animated: true, completion: nil)
    }

    func selectPairViewControllerDidCancel(_ sender:SelectPairViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
    
}

