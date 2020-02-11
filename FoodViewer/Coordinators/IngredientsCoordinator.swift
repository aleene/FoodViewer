//
//  IngredientsCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 10/02/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

class IngredientsCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var viewController: UIViewController? = nil
    
    weak var productPair: ProductPair? = nil
    
    private var coordinatorViewController: IngredientsTableViewController? {
        self.viewController as? IngredientsTableViewController
    }

    init(with viewController:UIViewController) {
        self.viewController = viewController
    }
    
    /// Show the image with the current display language
    func showImage(imageTitle: String?, imageData: ProductImageData?) {
        let childViewController = ImageViewController.instantiate()
        childViewController.coordinator = self
        childViewController.imageTitle = imageTitle
        childViewController.imageData = imageData
        presentAsFormSheet(childViewController)
    }

    func selectLanguage(with currentLanguageCode: String?, atAnchor button:UIButton) {
        let childViewController = SelectLanguageViewController.instantiate()
        childViewController.coordinator = self
        childViewController.configure(primaryLanguageCode: productPair?.primaryLanguageCode, currentLanguageCode: currentLanguageCode, languageCodes: productPair?.remoteProduct?.languageCodes)
        presentAsPopOver(childViewController, at: button)
    }

    func selectTraces(anchoredOn button:UIButton) {
        let childViewController = SelectPairViewController.instantiate()
        childViewController.coordinator = self
        childViewController.configure(original:       productPair?.tracesInterpreted?.list,
                    allPairs: OFFplists.manager.allAllergens,
                    multipleSelectionIsAllowed: true,
                    showOriginalsAsSelected: true,
                    assignedHeader: TranslatableStrings.SelectedTraces,
                    unAssignedHeader: TranslatableStrings.UnselectedTraces,
                    undefinedText: TranslatableStrings.NoTraceDefined)
        presentAsFormSheet(childViewController)
    }

    private func refresh() {
        coordinatorViewController?.refreshProduct()
    }

}


extension IngredientsCoordinator: ImageViewControllerCoordinator {
    
    func imageViewController(_ sender:ImageViewController, tapped barButton:UIBarButtonItem) {
        sender.dismiss(animated: true, completion: nil)
    }
}

extension IngredientsCoordinator: SelectLanguageViewControllerCoordinator {
    
    public func selectLanguageViewController(_ sender:SelectLanguageViewController, selected languageCode:String?) {
        coordinatorViewController?.currentLanguageCode = languageCode
        sender.dismiss(animated: true, completion: nil)
    }
    
    public func selectLanguageViewControllerDidCancel(_ sender:SelectLanguageViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
}


extension IngredientsCoordinator: SelectPairViewControllerCoordinator {
    
    func selectPairViewController(_ sender:SelectPairViewController, selected strings: [String]?) {
        productPair?.update(tracesTags: strings)
        self.refresh()
        sender.dismiss(animated: true, completion: nil)
    }

    func selectPairViewControllerDidCancel(_ sender:SelectPairViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
    
}

