//
//  NutrientsCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 10/02/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

final class NutrientsCoordinator: Coordinator {
    
    weak var parentCoordinator: Coordinator? = nil

    var childCoordinators: [Coordinator] = []
        
    var viewController: UIViewController? = nil
    
    private var coordinatorViewController: NutrientsTableViewController? {
        self.viewController as? NutrientsTableViewController
    }

    init(with coordinator: Coordinator?) {
        self.viewController = NutrientsTableViewController.instantiate()
        self.coordinatorViewController?.coordinator = self
        self.parentCoordinator = coordinator
    }
    
    init(with viewController: UIViewController?) {
        self.viewController = viewController
    }

    func show() {
        // Done in the viewController?
    }

    weak private var productPair: ProductPair? = nil

    // Show the image with the current display language
    // The coordinator does the right image selection
    func showImage(imageTitle: String?, imageSize: ProductImageSize?) {
        let coordinator = ImageViewCoordinator(with: self, imageTitle: imageTitle, imageSize: imageSize)
        childCoordinators.append(coordinator)
        coordinator.show()
    }

    func showNutrientUnitSelector(for productPair: ProductPair?, nutrient: Nutrient?, unit: NutritionFactUnit?, anchoredOn button:UIButton) {
        self.productPair = productPair
        let coordinator = NutrientUnitSelectorCoordinator(with: self, nutrient: nutrient, unit: unit, button: button)
        childCoordinators.append(coordinator)
        coordinator.show()
    }

    func showAddNutrientSelector(for productPair: ProductPair?, current nutrients:[String], anchoredOn button:UIButton) {
        self.productPair = productPair
        let coordinator = AddNutrientCoordinator(with: self, nutrients: nutrients, button: button)
        childCoordinators.append(coordinator)
        coordinator.show()
    }

    func showNutritionFactsTableStyleSelector(for productPair: ProductPair?, selected nutritionFactsTableStyle: NutritionFactsLabelStyle?, anchoredOn button:UIButton) {
        self.productPair = productPair
        let coordinator = SelectNutritionFactsTableStyleCoordinator(with: self, nutritionFactsTableStyle: nutritionFactsTableStyle, button: button)
        childCoordinators.append(coordinator)
        coordinator.show()
    }
    
    func showLanguageSelector(for productPair: ProductPair?, with currentLanguageCode: String?, atAnchor button: UIButton) {
        self.productPair = productPair
        let coordinator = SelectLanguageCoordinator(with: self, primaryLanguageCode: self.productPair?.primaryLanguageCode, currentLanguageCode: currentLanguageCode, languageCodes: self.productPair?.remoteProduct?.languageCodes, button: button)
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

extension NutrientsCoordinator: ImageCoordinatorProtocol {
    
    func imageViewController(_ sender:ImageViewController, tapped barButton:UIBarButtonItem) {
        sender.dismiss(animated: true, completion: nil)
    }
}

extension NutrientsCoordinator: SelectNutritionFactsTableStyleCoordinatorProtocol {
    func selectNutritionFactsTableStyleTableViewController(_ sender: SelectNutritionFactsTableStyleTableViewController, selected style: NutritionFactsLabelStyle?) {
        coordinatorViewController?.setNutritionFactsTableStyle(to: style)
        sender.dismiss(animated: true, completion: nil)
    }
    
    func selectNutritionFactsTableStyleTableViewControllerDidCancel(_ sender: SelectNutritionFactsTableStyleTableViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
    
    
}

extension NutrientsCoordinator: SelectNutrientCoordinatorProtocol {
    
    func selectNutrientUnitViewController(_ sender: SelectNutrientUnitViewController, nutrient: Nutrient?, unit: NutritionFactUnit?) {
        productPair?.update(nutrient:nutrient, unit:unit)
        sender.dismiss(animated: true, completion: nil)
    }

    func selectNutrientUnitViewControllerDidCancel(_ sender:SelectNutrientUnitViewController) {
        sender.dismiss(animated: true, completion: nil)
    }

}

extension NutrientsCoordinator : AddNutrientCoordinatorProtocol {
    
    func addNutrientViewController(_ sender:AddNutrientViewController, add nutrientTuple:(Nutrient, String, NutritionFactUnit)?) {
        if let newNutrientTuple = nutrientTuple {
            //var newNutrient = NutritionFactItem()
            //newNutrient.nutrient = newNutrientTuple.0
            // is it necessary to add the unit?
            //newNutrient.itemName = newNutrientTuple.1
            //newNutrient.valueUnit = newNutrientTuple.2
            productPair?.update(fact: NutritionFactItem.init(nutrient: newNutrientTuple.0, unit: newNutrientTuple.2))
        }
        coordinatorViewController?.refreshProduct()
        sender.dismiss(animated: true, completion: nil)
    }

    func addNutrientViewControllerDidCancel(_ sender:AddNutrientViewController) {
        sender.dismiss(animated: true, completion: nil)
    }

}

extension NutrientsCoordinator: SelectLanguageCoordinatorProtocol {
    
    public func selectLanguageViewController(_ sender:SelectLanguageViewController, selected languageCode:String?) {
        coordinatorViewController?.currentLanguageCode = languageCode
        sender.dismiss(animated: true, completion: nil)
    }
    
    public func selectLanguageViewControllerDidCancel(_ sender:SelectLanguageViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
}
