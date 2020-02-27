//
//  IdentificationCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 09/02/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

final class IdentificationCoordinator: Coordinator {

    var parentCoordinator: Coordinator? = nil

    var childCoordinators: [Coordinator] = []
    
    var childCoordinator: Coordinator? = nil
    
    var viewController: UIViewController? = nil
    
    private var coordinatorViewController: IdentificationTableViewController? {
        self.viewController as? IdentificationTableViewController
    }
    
    private enum Pagetype: Int {
        case mainLanguage = 0
        case addLanguage = 1
        case image = 2
    }
    
    // private var button: UIButton? = nil
    
    weak var productPair: ProductPair? = nil
    
    init(with coordinator: Coordinator?) {
        self.viewController = IdentificationTableViewController.instantiate()
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
        self.childCoordinator = coordinator
        coordinator.show()
    }
/**
Shows a modal viewController with a tableView that allows the user to select ONE language.

The selected language will used to set the primary (main) language of the product.
*/
    func selectMainLanguage() {
        let coordinator = SelectPairCoordinator.init(with:self,
                            original: productPair?.primaryLanguageCode != nil ?                   [productPair!.primaryLanguageCode] : nil,
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
    func addLanguages() {
        let coordinator = SelectPairCoordinator.init(with:self,
                                original: productPair?.remoteProduct?.languageCodes,
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
    func selectLanguage(currentLanguageCode: String?, atAnchor button:UIButton) {
        let coordinator = SelectLanguageCoordinator(with: self,
                                                    primaryLanguageCode: productPair?.primaryLanguageCode,
                                                    currentLanguageCode: currentLanguageCode,
                                                    languageCodes: productPair?.remoteProduct?.languageCodes,
                                                    button: button)
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

extension IdentificationCoordinator: ImageCoordinatorProtocol {
    
    func imageViewController(_ sender:ImageViewController, tapped barButton:UIBarButtonItem) {
        sender.dismiss(animated: true, completion: nil)
    }

    func imageViewControllerDidDisappear(_ sender:ImageViewController) {
        self.childCoordinator = nil
    }
}


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
                }
            }
        }
        sender.dismiss(animated: true, completion: nil)
    }

    func selectPairViewControllerDidCancel(_ sender:SelectPairViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
    
}

extension IdentificationCoordinator: SelectLanguageCoordinatorProtocol {
    
    public func selectLanguageViewController(_ sender:SelectLanguageViewController, selected languageCode:String?) {
        coordinatorViewController?.currentLanguageCode = languageCode
        sender.dismiss(animated: true, completion: nil)
    }
    
    public func selectLanguageViewControllerDidCancel(_ sender:SelectLanguageViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
}
