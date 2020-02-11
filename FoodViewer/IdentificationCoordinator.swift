//
//  IdentificationCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 09/02/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

final class IdentificationCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var viewController: UIViewController? = nil
    
    private var coordinatorViewController: IdentificationTableViewController? {
        self.viewController as? IdentificationTableViewController
    }
    
    private enum Pagetype: Int {
        case mainLanguage = 0
        case addLanguage = 1
        case image = 2
    }
        
    weak var productPair: ProductPair? = nil
    
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
/**
Shows a modal viewController with a tableView that allows the user to select ONE language.

The selected language will used to set the primary (main) language of the product.
*/
    func selectMainLanguage() {
        let childViewController = SelectPairViewController.instantiate()
        childViewController.coordinator = self
        childViewController.tag = Pagetype.mainLanguage.rawValue
        childViewController.configure(original: productPair?.primaryLanguageCode != nil ? [productPair!.primaryLanguageCode] : nil,
                    allPairs: OFFplists.manager.allLanguages,
                    multipleSelectionIsAllowed: false,
                    showOriginalsAsSelected: false,
                    assignedHeader: TranslatableStrings.SelectedLanguages,
                    unAssignedHeader: TranslatableStrings.UnselectedLanguages,
                    undefinedText: TranslatableStrings.NoLanguageDefined)
        presentAsFormSheet(childViewController)
    }
/**
Shows a modal viewController with a tableView that allows the user to select one or more languages.
     
The selected languages will be used as new (extra) product languages.
*/
    func addLanguages() {
        let childViewController = SelectPairViewController.instantiate()
        childViewController.coordinator = self
        childViewController.tag = Pagetype.addLanguage.rawValue
        childViewController.configure(original: productPair?.remoteProduct?.languageCodes,
            allPairs: OFFplists.manager.allLanguages,
            multipleSelectionIsAllowed: true,
            showOriginalsAsSelected: false,
            assignedHeader: TranslatableStrings.SelectedLanguages,
            unAssignedHeader: TranslatableStrings.UnselectedLanguages,
            undefinedText: TranslatableStrings.NoLanguageDefined)
        presentAsFormSheet(childViewController)
    }
/**
Shows a popover viewController with a pickerView that allows the user to select a language.
     
The selected language will be used to change the current display language of the product.
- parameters:
     - currentLanguageCode: the current languageCode that is displayed in the viewController. This languageCode will be selected in the pickerView;
     - button: the button that will be used to anchor the popover;
*/
    func selectLanguage(currentLanguageCode: String?, atAnchor button:UIButton) {
        let childViewController = SelectLanguageViewController.instantiate()
        childViewController.coordinator = self
        childViewController.configure(primaryLanguageCode: productPair?.primaryLanguageCode, currentLanguageCode: currentLanguageCode, languageCodes: productPair?.remoteProduct?.languageCodes)
        presentAsPopOver(childViewController, at: button)
    }

    private func refresh(with code:String?) {
        coordinatorViewController?.refreshInterface(with:code)
    }

}

extension IdentificationCoordinator: ImageViewControllerCoordinator {
    
    func imageViewController(_ sender:ImageViewController, tapped barButton:UIBarButtonItem) {
        sender.dismiss(animated: true, completion: nil)
    }
}

extension IdentificationCoordinator: SelectPairViewControllerCoordinator {
    
    func selectPairViewController(_ sender:SelectPairViewController, selected strings: [String]?) {
        if let validStrings = strings {
            if sender.tag == Pagetype.mainLanguage.rawValue {
                if let newLanguageCode = validStrings.first {
                    productPair?.update(primaryLanguageCode: newLanguageCode)
                    self.refresh(with:newLanguageCode)
                }

            } else if sender.tag == Pagetype.addLanguage.rawValue {
                for code in validStrings {
                    productPair?.update(addLanguageCode: code)
                }
                self.refresh(with:validStrings.first)
            }
        }
        sender.dismiss(animated: true, completion: nil)
    }

    func selectPairViewControllerDidCancel(_ sender:SelectPairViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
    
}

extension IdentificationCoordinator: SelectLanguageViewControllerCoordinator {
    
    public func selectLanguageViewController(_ sender:SelectLanguageViewController, selected languageCode:String?) {
        coordinatorViewController?.currentLanguageCode = languageCode
        sender.dismiss(animated: true, completion: nil)
    }
    
    public func selectLanguageViewControllerDidCancel(_ sender:SelectLanguageViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
}
