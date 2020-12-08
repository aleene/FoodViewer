//
//  SupplyChainCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 07/02/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

final class SupplyChainCoordinator: Coordinator {
    
// MARK: - Public variables
    
    weak var parentCoordinator: Coordinator? = nil

    var childCoordinators: [Coordinator] = []
    
    var viewController: UIViewController? = nil
    
// MARK: - Private variables
    
    weak private var productPair: ProductPair? = nil
    
    private var coordinatorViewController: SupplyChainTableViewController? {
        self.viewController as? SupplyChainTableViewController
    }
    
// MARK: - Initialisers
    
    init(with coordinator: Coordinator?) {
        self.viewController = SupplyChainTableViewController.instantiate()
        self.parentCoordinator = coordinator
    }

    init(with viewController:UIViewController) {
        self.viewController = viewController
    }
    
// MARK: - Child viewController presentation
    
    func show() {
        // Done in the viewController?
    }

    func selectFavoriteShop(for productPair: ProductPair?) {
        self.productPair = productPair
        let coordinator = FavoriteShopsCoordinator.init(with: self)
        childCoordinators.append(coordinator)
        coordinator.show()
    }
    
    func selectExpirationDate(for productPair: ProductPair?, anchoredOn button:UIButton) {
        self.productPair = productPair
        var currentDate: Date? = nil
        if let validName = productPair?.localProduct?.expirationDate {
            currentDate = validName
        } else if let validName = productPair?.remoteProduct?.expirationDate {
            currentDate = validName
        } else {
            currentDate = nil
        }
        let coordinator = SelectExpirationDateCoordinator(with: self, currentDate: currentDate, button: button)
        childCoordinators.append(coordinator)
        coordinator.show()
    }

    func selectCountry(for productPair: ProductPair?) {
        self.productPair = productPair
        let coordinator = SelectPairCoordinator.init(with:self,
                            original: productPair?.countriesInterpreted?.list,
                            allPairs: OFFplists.manager.allCountries,
                            multipleSelectionIsAllowed: true,
                            showOriginalsAsSelected: true,
                            tag: 0,
                            assignedHeader: TranslatableStrings.SelectedCountries,
                            unAssignedHeader: TranslatableStrings.UnselectedCountries,
                            undefinedText: TranslatableStrings.NoCountryDefined)
        childCoordinators.append(coordinator)
        coordinator.show()
    }
    
    func selectLanguage(primaryLanguageCode: String, currentLanguageCode: String?, productLanguageCodes: [String], atAnchor button: UIButton) {
        let coordinator = SelectLanguageCoordinator(with: self, primaryLanguageCode: primaryLanguageCode, currentLanguageCode: currentLanguageCode, languageCodes: productLanguageCodes, button: button)
        self.childCoordinators.append(coordinator)
        coordinator.show()
    }

    /// Show the robotoff question viewcontroller
    func showQuestion(for productPair: ProductPair?, question: RobotoffQuestion, image: ProductImageSize?) {
        self.productPair = productPair
        let coordinator = RobotoffQuestionCoordinator.init(with: self, question: question, image: image)
        self.childCoordinators.append(coordinator)
        coordinator.show()
    }

// MARK: - ViewController lifecycle
    
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

// MARK: - FavoriteShopsCoordinatorProtocol

extension SupplyChainCoordinator: FavoriteShopsCoordinatorProtocol {
    
    func favoriteShopsTableViewControllerAddFavoriteShop(_ sender: FavoriteShopsViewController) {
        // This viewController has its own coordinator
        if let coordinator = childCoordinators.first(where: ({ $0 is FavoriteShopsCoordinator }) ) as? FavoriteShopsCoordinator {
            coordinator.showAddFavoriteShopTableViewController()
        }
    }
    
    func favoriteShopsTableViewController(_ sender:FavoriteShopsViewController, selected shop:(String, Address)?) {
        productPair?.update(shop: shop)
        sender.dismiss(animated: true, completion: nil)
    }

    func favoriteShopsTableViewControllerDidCancel(_ sender:FavoriteShopsViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - SelectExpirationDateCoordinatorProtocol

extension SupplyChainCoordinator: SelectExpirationDateCoordinatorProtocol {
    
    func selectExpirationDateViewController(_ sender:SelectExpirationDateViewController, selected date:Date?) {
        productPair?.update(expirationDate: date)
        sender.dismiss(animated: true, completion: nil)
    }

    func selectExpirationDateViewControllerDidCancel(_ sender:SelectExpirationDateViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - SelectPairCoordinatorProtocol

extension SupplyChainCoordinator: SelectPairCoordinatorProtocol {
    
    func selectPairViewController(_ sender:SelectPairViewController, selected strings: [String]?, tag: Int) {
        productPair?.update(countries: strings)
        sender.dismiss(animated: true, completion: nil)
    }

    func selectPairViewControllerDidCancel(_ sender:SelectPairViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
    
}

extension SupplyChainCoordinator: SelectLanguageCoordinatorProtocol {
    
    public func selectLanguageViewController(_ sender:SelectLanguageViewController, selected languageCode:String?) {
        coordinatorViewController?.currentLanguageCode = languageCode
        sender.dismiss(animated: true, completion: nil)
    }
    
    public func selectLanguageViewControllerDidCancel(_ sender:SelectLanguageViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
}

// MARK: - RobotoffQuestionCoordinatorProtocol

extension SupplyChainCoordinator: RobotoffQuestionCoordinatorProtocol {
    func robotoffQuestionTableViewController(_ sender: RobotoffQuestionViewController, answered question: RobotoffQuestion?) {
        guard let validProductPair = productPair else { return }
        guard let validQuestion = question else { return }
        OFFProducts.manager.startRobotoffUpload(for: validQuestion, in: validProductPair)
        sender.dismiss(animated: true, completion: nil)
    }
}
