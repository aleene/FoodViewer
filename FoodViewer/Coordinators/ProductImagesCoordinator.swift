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
class ProductImagesCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var viewController: UIViewController? = nil
    
    weak var productPair: ProductPair? = nil

    private var coordinatorViewController: ProductImagesCollectionViewController? {
        self.viewController as? ProductImagesCollectionViewController
    }

    init(with viewController:UIViewController) {
        self.viewController = viewController
    }
/**
Shows a modal formSheet viewController with a product image.

The caller determines the image that will be shown.
 - parameters:
    - imageTitle: the title to be displayed on the viewController;
    - imageData: the data of the image to be shown;
*/
    func showImage(imageTitle: String?, imageData: ProductImageData?) {
        let childViewController = ImageViewController.instantiate()
        childViewController.coordinator = self
        childViewController.imageTitle = imageTitle
        childViewController.imageData = imageData
        presentAsFormSheet(childViewController)
    }
    
    func showSelectLanguageAndImageType(languageCodes: [String], key: String?) {
        let childViewController = SelectLanguageAndImageTypeViewController.instantiate()
        childViewController.coordinator = self
        childViewController.configure(languageCodes:languageCodes, key:key)
        presentAsFormSheet(childViewController)
    }

}

extension ProductImagesCoordinator: ImageViewControllerCoordinator {
    
    func imageViewController(_ sender:ImageViewController, tapped barButton:UIBarButtonItem) {
        sender.dismiss(animated: true, completion: nil)
    }
    
}

extension ProductImagesCoordinator : SelectLanguageAndImageTypeViewControllerCoordinator {
    
    func selectLanguageAndImageTypeViewController(_ sender: SelectLanguageAndImageTypeViewController, languageCode: String?, imageCategory: ImageTypeCategory?, key: String?) {
        productPair?.updateImage(key: key, languageCode: languageCode, imageType: imageCategory)
        sender.dismiss(animated: true, completion: nil)
    }
    
    func selectLanguageAndImageTypeViewControllerDidCancel(_ sender: SelectLanguageAndImageTypeViewController) {
        sender.dismiss(animated: true, completion: nil)
    }

}
