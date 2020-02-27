//
//  SelectLanguageAndImageTypeCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 19/02/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//


import UIKit

final class SelectLanguageAndImageTypeCoordinator: Coordinator {
    
    var childCoordinator: Coordinator?
    
    var parentCoordinator: Coordinator? = nil
    
    var childCoordinators: [Coordinator] = []

    internal var viewController: UIViewController? = nil
        
    private var coordinatorViewController: SelectLanguageAndImageTypeViewController? {
        self.viewController as? SelectLanguageAndImageTypeViewController
    }

    private var button: UIButton? = nil
    
    init(with coordinator: Coordinator?) {
        self.parentCoordinator = coordinator
        self.viewController = SelectLanguageAndImageTypeViewController.instantiate()
        if let protocolCoordinator = coordinator as? SelectLanguageAndImageTypeCoordinatorProtocol {
            self.coordinatorViewController?.protocolCoordinator = protocolCoordinator
        } else {
            print("SelectLanguageAndImageTypeCoordinator: coordinator does not conform to protocol")
        }
    }
    
    convenience init(with coordinator: Coordinator?, languageCodes:[String], key:String?) {
        self.init(with: coordinator)
        coordinatorViewController?.configure(languageCodes:languageCodes, key:key)
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

