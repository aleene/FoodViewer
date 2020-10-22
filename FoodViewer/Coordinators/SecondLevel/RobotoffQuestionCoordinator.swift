//
//  RobotoffQuestionCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 22/10/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

/**
This class coordinates the viewControllers initiated by `RobotoffQuestionCoordinator`.
 
Variables:
 - `childCoordinators`: the other coordinators that are required in child viewControllers;
 - `viewController`: the main viewController that is managed;
 
Functions:
  - `init(with:)` the initalisation method
    - Parameter :  viewController that needs to be managed
 
Managed viewControllers:
 - none
*/
final class RobotoffQuestionCoordinator: Coordinator {
    
    var childCoordinator: Coordinator?
    
    var parentCoordinator: Coordinator? = nil

    var childCoordinators: [Coordinator] = []

    var viewController: UIViewController? = nil

    private var coordinatorViewController: RobotoffQuestionViewController? {
        self.viewController as? RobotoffQuestionViewController
    }

    init(with coordinator: Coordinator?) {
        self.viewController = RobotoffQuestionViewController.instantiate()
        self.parentCoordinator = coordinator
        self.coordinatorViewController?.coordinator = self
        if let protocolCoordinator = coordinator as? RobotoffQuestionCoordinatorProtocol {
            self.coordinatorViewController?.protocolCoordinator = protocolCoordinator
        } else {
            print("RobotoffQuestionViewController: coordinator does not conform to protocol")
        }
    }
    
    // pass on the data
    convenience init(with coordinator: Coordinator?,
                   question: RobotoffQuestion,
                   image: ProductImageSize?) {
        self.init(with: coordinator)
        self.coordinatorViewController?.configure(
            question: question,
            image: image )
    }

    func show() {
        self.parentCoordinator?.presentAsFormSheet(self.viewController)
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


