//
//  ProductImagesCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 12/02/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

/**
This class coordinates the viewControllers initiated by `ProductImagesCoordinator`.
 
Variables:
 - `childCoordinators`: the other coordinators that are required in child viewControllers;
 - `viewController`: the main viewController that is managed;
 
Functions:
  - `init(with:)` the initalisation method
    - Parameter :  viewController that needs to be managed
 
Managed viewControllers:
 - `ImageViewController`: allows to show an image in detail. Any flow is managed by this Coordinator through the `ImageViewControllerCoordinator` protocol.
*/
final class ProductImagesCoordinator: Coordinator {
    
    weak var parentCoordinator: Coordinator? = nil
    
    var childCoordinators: [Coordinator] = []
        
    var viewController: UIViewController? = nil
    
    weak var productPair: ProductPair? = nil

    private var coordinatorViewController: ProductImagesCollectionViewController? {
        self.viewController as? ProductImagesCollectionViewController
    }
    
    init(with coordinator: Coordinator?) {
        self.viewController = ProductImagesCollectionViewController.instantiate()
        self.parentCoordinator = coordinator
    }

    init(with viewController:UIViewController) {
        self.viewController = viewController
    }
    
    func show() {
        // Done in the viewController?
    }

/**
Shows a modal formSheet viewController with a product image.

The caller determines the image that will be shown.
 - parameters:
    - imageTitle: the title to be displayed on the viewController;
    - imageData: the data of the image to be shown;
*/
    func showImage(imageTitle: String?, imageData: ProductImageData?) {
        let coordinator = ImageViewCoordinator(with: self, imageTitle: imageTitle, imageData: imageData)
        self.childCoordinators.append(coordinator)
        coordinator.show()
    }
    
    func showSelectLanguageAndImageType(languageCodes: [String], key: String?) {
        let coordinator = SelectLanguageAndImageTypeCoordinator(with: self, languageCodes:languageCodes, key:key)
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

extension ProductImagesCoordinator: ImageCoordinatorProtocol {
    
    func imageViewController(_ sender:ImageViewController, tapped barButton:UIBarButtonItem) {
        sender.dismiss(animated: true, completion: nil)
    }
    
    func imageViewControllerDidDisappear(_ sender:ImageViewController) {
    }
}

extension ProductImagesCoordinator : SelectLanguageAndImageTypeCoordinatorProtocol {
    
    func selectLanguageAndImageTypeViewController(_ sender: SelectLanguageAndImageTypeViewController, languageCode: String?, imageCategory: ImageTypeCategory?, key: String?) {
        productPair?.updateImage(key: key, languageCode: languageCode, imageType: imageCategory)
        sender.dismiss(animated: true, completion: nil)
    }
    
    func selectLanguageAndImageTypeViewControllerDidCancel(_ sender: SelectLanguageAndImageTypeViewController) {
        sender.dismiss(animated: true, completion: nil)
    }

}
