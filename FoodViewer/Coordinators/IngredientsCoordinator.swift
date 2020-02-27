//
//  IngredientsCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 10/02/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

final class IngredientsCoordinator: Coordinator {
  
    weak var parentCoordinator: Coordinator? = nil
      
    var childCoordinators: [Coordinator] = []
  
    var viewController: UIViewController? = nil
    
    weak var productPair: ProductPair? = nil
    
    private var coordinatorViewController: IngredientsTableViewController? {
        self.viewController as? IngredientsTableViewController
    }
    
    init(with coordinator: Coordinator?) {
        self.viewController = IngredientsTableViewController.instantiate()
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

    func selectLanguage(with currentLanguageCode: String?, atAnchor button:UIButton) {
        let coordinator = SelectLanguageCoordinator(with: self, primaryLanguageCode: productPair?.primaryLanguageCode, currentLanguageCode: currentLanguageCode, languageCodes: productPair?.remoteProduct?.languageCodes, button: button)
        childCoordinators.append(coordinator)
        coordinator.show()
    }

    func selectTraces(anchoredOn button:UIButton) {
        let coordinator = SelectPairCoordinator.init(with:self,
                            original: productPair?.tracesInterpreted?.list,
                              allPairs: OFFplists.manager.allAllergens,
                              multipleSelectionIsAllowed: true,
                              showOriginalsAsSelected: true,
                              tag: 0,
                              assignedHeader: TranslatableStrings.SelectedTraces,
                              unAssignedHeader: TranslatableStrings.UnselectedTraces,
                              undefinedText: TranslatableStrings.NoTraceDefined)
        childCoordinators.append(coordinator)
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


extension IngredientsCoordinator: ImageCoordinatorProtocol {
    
    func imageViewController(_ sender:ImageViewController, tapped barButton:UIBarButtonItem) {
        sender.dismiss(animated: true, completion: nil)
    }
}

extension IngredientsCoordinator: SelectLanguageCoordinatorProtocol {
    
    public func selectLanguageViewController(_ sender:SelectLanguageViewController, selected languageCode:String?) {
        coordinatorViewController?.currentLanguageCode = languageCode
        sender.dismiss(animated: true, completion: nil)
    }
    
    public func selectLanguageViewControllerDidCancel(_ sender:SelectLanguageViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
}


extension IngredientsCoordinator: SelectPairCoordinatorProtocol {
    
    func selectPairViewController(_ sender:SelectPairViewController, selected strings: [String]?, tag: Int) {
        productPair?.update(tracesTags: strings)
        sender.dismiss(animated: true, completion: nil)
    }

    func selectPairViewControllerDidCancel(_ sender:SelectPairViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
    
}

