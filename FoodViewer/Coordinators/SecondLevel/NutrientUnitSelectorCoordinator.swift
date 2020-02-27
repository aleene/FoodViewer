//
//  NutrientUnitSelectorCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 19/02/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//


import UIKit

final class NutrientUnitSelectorCoordinator: Coordinator {
    
    var childCoordinator: Coordinator?

    var parentCoordinator: Coordinator? = nil
    
    var childCoordinators: [Coordinator] = []

    var viewController: UIViewController? = nil
        
    var coordinatorViewController: SelectNutrientUnitViewController? {
        self.viewController as? SelectNutrientUnitViewController
    }

    private var button: UIButton? = nil
    
    init(with coordinator: Coordinator?) {
        self.parentCoordinator = coordinator
        self.viewController = SelectNutrientUnitViewController.instantiate()
        if let protocolCoordinator = coordinator as? SelectNutrientCoordinatorProtocol {
            self.coordinatorViewController?.protocolCoordinator = protocolCoordinator
        } else {
            print("NutrientUnitSelectorCoordinator: coordinator does not conform to protocol")
        }
    }
    
    convenience init(with coordinator: Coordinator?, nutrient: Nutrient?, unit: NutritionFactUnit?, button: UIButton) {
        self.init(with: coordinator)
        coordinatorViewController?.configure(nutrient: nutrient, unit: unit)
        self.button = button
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

