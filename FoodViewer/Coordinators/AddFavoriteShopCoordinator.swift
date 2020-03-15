//
//  AddFavoriteShopCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 07/02/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

final class AddFavoriteShopCoordinator: Coordinator {
    
    var childCoordinator: Coordinator?

    var parentCoordinator: Coordinator? = nil

    var childCoordinators: [Coordinator] = []

    var viewController: UIViewController? = nil
    
    private var coordinatorViewController: AddFavoriteShopTableViewController? {
        self.viewController as? AddFavoriteShopTableViewController
    }

    init(with coordinator: Coordinator?) {
        self.viewController = AddFavoriteShopTableViewController.instantiate()
        if let validCoordinator = coordinator as? AddFavoriteShopCoordinatorProtocol {
            self.coordinatorViewController?.protocolCoordinator = validCoordinator
        }
        self.coordinatorViewController?.coordinator = self
        self.parentCoordinator = coordinator
    }

    func show() {
        self.parentCoordinator?.presentAsFormSheet(viewController)
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

