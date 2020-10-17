//
//  EnvironmentCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 16/10/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

final class EnvironmentCoordinator: Coordinator {

    weak var parentCoordinator: Coordinator? = nil
      
    var childCoordinators: [Coordinator] = []
  
    var viewController: UIViewController? = nil
    
    weak private var productPair: ProductPair? = nil
    
    private var coordinatorViewController: EnvironmentTableViewController? {
        self.viewController as? EnvironmentTableViewController
    }
    
    init(with coordinator: Coordinator?) {
        self.viewController = EnvironmentTableViewController.instantiate()
        self.parentCoordinator = coordinator
    }

    init(with viewController:UIViewController) {
        self.viewController = viewController
    }
    
    func show() {
        // Done in the viewController?
    }

    /// Show the image with the current display language
    func showImage(imageTitle: String?, imageData: ProductImageData?) {
        
        let coordinator = ImageViewCoordinator(with: self, imageTitle: imageTitle, imageData: imageData)
        self.childCoordinators.append(coordinator)
        coordinator.show()
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


extension EnvironmentCoordinator: ImageCoordinatorProtocol {
    
    func imageViewController(_ sender:ImageViewController, tapped barButton:UIBarButtonItem) {
        sender.dismiss(animated: true, completion: nil)
    }
}

