//
//  ImageViewCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 19/02/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

final class ImageViewCoordinator: Coordinator {
    
    var childCoordinator: Coordinator?
    
    var parentCoordinator: Coordinator? = nil

    var childCoordinators: [Coordinator] = []

    var viewController: UIViewController? = nil
        
    private var coordinatorViewController: ImageViewController? {
        self.viewController as? ImageViewController
    }

    init(with coordinator: Coordinator?) {
        self.viewController = ImageViewController.instantiate()
        self.coordinatorViewController?.coordinator = self
        if let protocolCoordinator = coordinator as? ImageCoordinatorProtocol {
            self.coordinatorViewController?.protocolCoordinator = protocolCoordinator
        } else {
            print("ImageViewCoordinator: coordinator does not conform to protocol")
        }
        self.parentCoordinator = coordinator
    }
    
    convenience init(with coordinator: Coordinator?, imageTitle: String?, imageSize: ProductImageSize?) {
        self.init(with: coordinator)
        self.coordinatorViewController?.imageTitle = imageTitle
        self.coordinatorViewController!.imageSize = imageSize
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

