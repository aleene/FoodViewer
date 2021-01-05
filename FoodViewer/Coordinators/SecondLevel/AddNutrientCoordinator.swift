//
//  AddNutrientCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 19/02/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

final class AddNutrientCoordinator: Coordinator {
    
    var childCoordinator: Coordinator?

    var parentCoordinator: Coordinator? = nil
    
    var childCoordinators: [Coordinator] = []

    var viewController: UIViewController? = nil
        
    var coordinatorViewController: AddNutrientViewController? {
        self.viewController as? AddNutrientViewController
    }

    private var button: UIButton? = nil
    
    init(with coordinator: Coordinator?) {
        self.parentCoordinator = coordinator
        self.viewController = AddNutrientViewController.instantiate()
        if let protocolCoordinator = coordinator as? AddNutrientCoordinatorProtocol {
            self.coordinatorViewController?.protocolCoordinator = protocolCoordinator
        } else {
            print("AddNutrientCoordinator: coordinator does not conform to protocol")
        }
    }
    
    convenience init(with coordinator: Coordinator?,
                     nutrients:[String],
                     nutritionFactsPreparationStyle: NutritionFactsPreparationStyle,
                     button:UIButton) {
        self.init(with: coordinator)
        coordinatorViewController?.configure(existing: nutrients,
                                             nutritionFactsPreparationStyle: nutritionFactsPreparationStyle)
        self.button = button
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

