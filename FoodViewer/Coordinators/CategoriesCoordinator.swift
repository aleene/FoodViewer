//
//  CategoriesCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 08/02/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

final class CategoriesCoordinator: Coordinator {
    
// MARK: - Public variables

    var childCoordinator: Coordinator?
    
    weak var parentCoordinator: Coordinator? = nil
    
    var childCoordinators: [Coordinator] = []
    
    var viewController: UIViewController? = nil
    
// MARK: - Private variables

    weak private var productPair: ProductPair? = nil
    
    private var coordinatorViewController: CategoriesTableViewController? {
        self.viewController as? CategoriesTableViewController
    }

// MARK: - Initialisation

    init(with coordinator: Coordinator?) {
        self.viewController = CategoriesTableViewController.instantiate()
        self.coordinatorViewController?.coordinator = self
        self.parentCoordinator = coordinator
    }

    init(with viewController:UIViewController) {
        self.viewController = viewController
    }
        
// MARK: - Child viewControllers
        
    func show() {
        // Done in the viewController?
    }
    
    /// Show the robotoff question viewcontroller
    func showQuestion(for productPair: ProductPair?, question: RobotoffQuestion, image: ProductImageSize?) {
        self.productPair = productPair
        let coordinator = RobotoffQuestionCoordinator.init(with: self, question: question, image: image)
        self.childCoordinators.append(coordinator)
        coordinator.show()
    }

    func selectCategory(for productPair: ProductPair?) {
        self.productPair = productPair
        let coordinator = SelectPairCoordinator.init(with:self,
                                                     original: self.productPair?.categoriesInterpreted?.list,
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

// MARK: - Lifecycle
     
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

// MARK: - SelectPairCoordinatorProtocol

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

// MARK: - RobotoffQuestionCoordinatorProtocol

extension CategoriesCoordinator: RobotoffQuestionCoordinatorProtocol {
    func robotoffQuestionTableViewController(_ sender: RobotoffQuestionViewController, answered question: RobotoffQuestion?) {
        guard let validProductPair = productPair else { return }
        guard let validQuestion = question else { return }
        OFFProducts.manager.startRobotoffUpload(for: validQuestion, in: validProductPair)
        sender.dismiss(animated: true, completion: nil)
    }
}

