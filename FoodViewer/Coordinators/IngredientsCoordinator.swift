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
    
    weak private var productPair: ProductPair? = nil
        
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
    func showImage(imageTitle: String?, imageSize: ProductImageSize?) {
        
        let coordinator = ImageViewCoordinator(with: self, imageTitle: imageTitle, imageSize: imageSize)
        self.childCoordinators.append(coordinator)
        coordinator.show()
    }

    func selectLanguage(primaryLanguageCode: String, currentLanguageCode: String?, productLanguageCodes: [String], atAnchor button: UIButton) {
        let coordinator = SelectLanguageCoordinator(with: self, primaryLanguageCode: primaryLanguageCode, currentLanguageCode: currentLanguageCode, languageCodes: productLanguageCodes, button: button)
        self.childCoordinators.append(coordinator)
        coordinator.show()
    }

    func selectTraces(for productPair: ProductPair?, anchoredOn button:UIButton) {
        self.productPair = productPair
        let coordinator = SelectPairCoordinator.init(with:self,
                                                     original: self.productPair?.tracesInterpreted?.list,
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
    
    /// Show the robotoff question viewcontroller
    func showQuestion(for productPair: ProductPair?, question: RobotoffQuestion, image: ProductImageSize?) {
        self.productPair = productPair
        let coordinator = RobotoffQuestionCoordinator.init(with: self, question: question, image: image)
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

extension IngredientsCoordinator: RobotoffQuestionCoordinatorProtocol {
    func robotoffQuestionTableViewController(_ sender: RobotoffQuestionViewController, answered question: RobotoffQuestion?) {
        guard let validProductPair = productPair else { return }
        guard let validQuestion = question else { return }
        OFFProducts.manager.startRobotoffUpload(for: validQuestion, in: validProductPair)
        sender.dismiss(animated: true, completion: nil)
    }
}

