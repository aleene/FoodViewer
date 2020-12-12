//
//  EcoscoreCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 10/12/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

final class EcoscoreCoordinator: Coordinator {
    
    var childCoordinator: Coordinator?

    var parentCoordinator: Coordinator? = nil
    
    var childCoordinators: [Coordinator] = []

    var viewController: UIViewController? = nil
        
    var coordinatorViewController: EcoscoreTableViewController? {
        self.viewController as? EcoscoreTableViewController
    }
    
    init(with coordinator: Coordinator?) {
        self.parentCoordinator = coordinator
        self.viewController = EcoscoreTableViewController.instantiate()
        if let protocolCoordinator = coordinator as? EcoscoreCoordinatorProtocol {
            self.coordinatorViewController?.protocolCoordinator = protocolCoordinator
        } else {
            print("EcoscoreCoordinator: coordinator does not conform to protocol")
        }
    }
    
    convenience init(with coordinator: Coordinator?, ecoscoreData: OFFProductEcoscoreData) {
        self.init(with: coordinator)
        coordinatorViewController?.configure(ecoscoreData: ecoscoreData)
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

