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
    
    func showImage(imageTitle: String?, imageData: ProductImageData?) {
        let childViewController = ImageViewController.instantiate()
        childViewController.coordinator = self
        childViewController.imageTitle = imageTitle
        childViewController.imageData = imageData
        viewController?.present(childViewController, animated: true, completion: nil)
    }
    
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
        viewController?.present(childViewController, animated: true, completion: nil)
    }

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
        viewController?.present(childViewController, animated: true, completion: nil)
    }
    
    func selectLanguage(currentLanguageCode: String?) {
        let childViewController = SelectLanguageViewController.instantiate()
        childViewController.coordinator = self
        childViewController.configure(primaryLanguageCode: productPair?.primaryLanguageCode, currentLanguageCode: currentLanguageCode, languageCodes: productPair?.remoteProduct?.languageCodes)
        viewController?.present(childViewController, animated: true, completion: nil)
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
