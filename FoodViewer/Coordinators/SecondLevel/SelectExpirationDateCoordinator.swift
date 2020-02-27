//
//  SelectExpirationDateCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 19/02/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

final class SelectExpirationDateCoordinator: Coordinator {
    
    var childCoordinator: Coordinator?
    
    var parentCoordinator: Coordinator? = nil
    
    var childCoordinators: [Coordinator] = []

    internal var viewController: UIViewController? = nil
        
    private var coordinatorViewController: SelectExpirationDateViewController? {
        self.viewController as? SelectExpirationDateViewController
    }

    private var button: UIButton? = nil
    
    init(with coordinator: Coordinator?) {
        self.parentCoordinator = coordinator
        self.viewController = SelectExpirationDateViewController.instantiate()
        if let protocolCoordinator = coordinator as? SelectExpirationDateCoordinatorProtocol {
            self.coordinatorViewController?.protocolCoordinator = protocolCoordinator
        } else {
            print("SelectExpirationDateCoordinator: coordinator does not conform to protocol")
        }
    }
    
    convenience init(with coordinator: Coordinator?, currentDate: Date?, button: UIButton) {
        self.init(with: coordinator)
        self.button = button
        self.coordinatorViewController?.currentDate = currentDate
    }
    
    func show() {
        self.parentCoordinator?.presentAsPopOver(viewController, at: button)
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

