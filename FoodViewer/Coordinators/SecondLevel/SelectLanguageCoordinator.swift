//
//  SelectLanguageCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 19/02/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

final class SelectLanguageCoordinator: Coordinator {
    
    var childCoordinator: Coordinator?
    
    var parentCoordinator: Coordinator? = nil
    
    var childCoordinators: [Coordinator] = []

    internal var viewController: UIViewController? = nil
        
    private var coordinatorViewController: SelectLanguageViewController? {
        self.viewController as? SelectLanguageViewController
    }

    private var button: UIButton? = nil
    
    init(with coordinator: Coordinator?) {
        self.parentCoordinator = coordinator
        self.viewController = SelectLanguageViewController.instantiate()
        if let protocolCoordinator = coordinator as? SelectLanguageCoordinatorProtocol {
            self.coordinatorViewController?.protocolCoordinator = protocolCoordinator
        } else {
            print("SelectLanguageCoordinator: coordinator does not conform to protocol")
        }
    }
    
    convenience init(with coordinator: Coordinator?, primaryLanguageCode: String?, currentLanguageCode: String?, languageCodes: [String]?, button: UIButton) {
        self.init(with: coordinator)
        self.button = button
        coordinatorViewController?.configure(primaryLanguageCode: primaryLanguageCode, currentLanguageCode: currentLanguageCode, languageCodes: languageCodes)
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

