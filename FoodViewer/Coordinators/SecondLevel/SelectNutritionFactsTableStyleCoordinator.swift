//
//  SelectNutritionFactsTableStyleCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 19/02/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//


import UIKit

final class SelectNutritionFactsTableStyleCoordinator: Coordinator {
        
    weak var parentCoordinator: Coordinator? = nil
    
    /// The child coordinator currently managed by this coordinator. If the child viewcontroller dispaaears this coordinator is no longer needed.
    var childCoordinators: [Coordinator] = []

    internal var viewController: UIViewController? = nil
        
    private var coordinatorViewController: SelectNutritionFactsTableStyleTableViewController? {
        self.viewController as? SelectNutritionFactsTableStyleTableViewController
    }

    private var button: UIButton? = nil
    
    init(with coordinator: Coordinator?) {
        self.parentCoordinator = coordinator
        self.viewController = SelectNutritionFactsTableStyleTableViewController.instantiate()
        if let protocolCoordinator = coordinator as? SelectNutritionFactsTableStyleCoordinatorProtocol {
            self.coordinatorViewController?.protocolCoordinator = protocolCoordinator
        } else {
            print("SelectNutritionFactsTableStyleCoordinator: coordinator does not conform to protocol")
        }
    }
    
    convenience init(with coordinator: Coordinator?, nutritionFactsTableStyle: NutritionFactsLabelStyle?, button: UIButton) {
        self.init(with: coordinator)
        coordinatorViewController?.configure(selected:nutritionFactsTableStyle)
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

