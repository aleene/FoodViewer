//
//  IdentificationCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 09/02/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

final class IdentificationCoordinator: Coordinator {

// MARK: - Public variables
    
    var parentCoordinator: Coordinator? = nil

    var childCoordinators: [Coordinator] = []
    
    var childCoordinator: Coordinator? = nil
    
    var viewController: UIViewController? = nil
    
// MARK: - Private variables
    
    private var coordinatorViewController: IdentificationTableViewController? {
        self.viewController as? IdentificationTableViewController
    }
    
    private enum Pagetype: Int {
        case mainLanguage = 0
        case addLanguage = 1
        case image = 2
    }
        
    weak private var productPair: ProductPair? = nil
    
// MARK: - Initialisation
    
    init(with coordinator: Coordinator?) {
        self.viewController = IdentificationTableViewController.instantiate()
        self.parentCoordinator = coordinator
    }

    init(with viewController:UIViewController) {
        self.viewController = viewController
    }
    
// MARK: - Child viewControllers
    
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
    func showImage(imageTitle: String?, imageSize: ProductImageSize?) {
        let coordinator = ImageViewCoordinator(with: self, imageTitle: imageTitle, imageSize: imageSize)
        self.childCoordinator = coordinator
        coordinator.show()
    }
/**
Shows a modal viewController with a tableView that allows the user to select ONE language.

The selected language will used to set the primary (main) language of the product.
*/
    func selectMainLanguage(for productPair: ProductPair?) {
        self.productPair = productPair
        let coordinator = SelectPairCoordinator.init(with:self,
                                                     original: self.productPair?.primaryLanguageCode != nil ?                   [self.productPair!.primaryLanguageCode] : nil,
                              allPairs: OFFplists.manager.allLanguages,
                              multipleSelectionIsAllowed: false,
                              showOriginalsAsSelected: false,
                              tag: Pagetype.mainLanguage.rawValue,
                              assignedHeader: TranslatableStrings.SelectedLanguages,
                              unAssignedHeader: TranslatableStrings.UnselectedLanguages,
                              undefinedText: TranslatableStrings.NoLanguageDefined)
        childCoordinators.append(coordinator)
        coordinator.show()
    }
/**
Shows a modal viewController with a tableView that allows the user to select one or more languages.
     
The selected languages will be used as new (extra) product languages.
*/
    func addLanguages(for productPair: ProductPair?) {
        self.productPair = productPair
        let coordinator = SelectPairCoordinator.init(with:self,
                                                     original: self.productPair?.remoteProduct?.languageCodes,
                                  allPairs: OFFplists.manager.allLanguages,
                                  multipleSelectionIsAllowed: true,
                                  showOriginalsAsSelected: false,
                                  tag: Pagetype.addLanguage.rawValue,
                                  assignedHeader: TranslatableStrings.SelectedLanguages,
                                  unAssignedHeader: TranslatableStrings.UnselectedLanguages,
                                  undefinedText: TranslatableStrings.NoLanguageDefined)
        childCoordinators.append(coordinator)
        coordinator.show()
    }
/**
Shows a popover viewController with a pickerView that allows the user to select a language.
     
The selected language will be used to change the current display language of the product.
- parameters:
     - currentLanguageCode: the current languageCode that is displayed in the viewController. This languageCode will be selected in the pickerView;
     - button: the button that will be used to anchor the popover;
*/
    func selectLanguage(primaryLanguageCode: String?, currentLanguageCode: String?, productLanguageCodes: [String], atAnchor button:UIButton) {
        let coordinator = SelectLanguageCoordinator(with: self,
                                                    primaryLanguageCode: primaryLanguageCode,
                                                    currentLanguageCode: currentLanguageCode,
                                                    languageCodes: productLanguageCodes,
                                                    button: button)
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

// MARK: - Lifecycle
 
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

// MARK: - ImageCoordinatorProtocol
extension IdentificationCoordinator: ImageCoordinatorProtocol {
    
    func imageViewController(_ sender:ImageViewController, tapped barButton:UIBarButtonItem) {
        sender.dismiss(animated: true, completion: nil)
    }

    func imageViewControllerDidDisappear(_ sender:ImageViewController) {
        self.childCoordinator = nil
    }
}

// MARK: - SelectPairCoordinatorProtocol

extension IdentificationCoordinator: SelectPairCoordinatorProtocol {
    
    func selectPairViewController(_ sender:SelectPairViewController, selected strings: [String]?, tag:Int) {
        if let validStrings = strings {
            if tag == Pagetype.mainLanguage.rawValue {
                if let newLanguageCode = validStrings.first {
                    productPair?.update(primaryLanguageCode: newLanguageCode)
                }

            } else if sender.tag == Pagetype.addLanguage.rawValue {
                for code in validStrings {
                    productPair?.update(addLanguageCode: code)
                    // we need to tell the interface that it should change to the new language
                    coordinatorViewController?.currentLanguageCode = code
                    // Note that this will result in two refreshes of the interface:
                    // 1 - for a changed local product (extra languageCode)
                    // 2 - for a new interface language code
                }
            }
        }
        sender.dismiss(animated: true, completion: nil)
    }

    func selectPairViewControllerDidCancel(_ sender:SelectPairViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - SelectLanguageCoordinatorProtocol

extension IdentificationCoordinator: SelectLanguageCoordinatorProtocol {
    
    public func selectLanguageViewController(_ sender:SelectLanguageViewController, selected languageCode:String?) {
        coordinatorViewController?.currentLanguageCode = languageCode
        sender.dismiss(animated: true, completion: nil)
    }
    
    public func selectLanguageViewControllerDidCancel(_ sender:SelectLanguageViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
}

// MARK: - RobotoffQuestionCoordinatorProtocol

extension IdentificationCoordinator: RobotoffQuestionCoordinatorProtocol {
    func robotoffQuestionTableViewController(_ sender: RobotoffQuestionViewController, answered question: RobotoffQuestion?) {
        guard let validProductPair = productPair else { return }
        guard let validQuestion = question else { return }
        OFFProducts.manager.startRobotoffUpload(for: validQuestion, in: validProductPair)
        sender.dismiss(animated: true, completion: nil)
    }
}
