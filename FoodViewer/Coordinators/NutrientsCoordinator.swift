//
//  NutrientsCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 10/02/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

class NutrientsCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    var viewController: UIViewController? = nil
    
    weak var productPair: ProductPair? = nil
    
    private var coordinatorViewController: NutrientsTableViewController? {
        self.viewController as? NutrientsTableViewController
    }

    init(with viewController:UIViewController) {
        self.viewController = viewController
    }
    
    // Show the image with the current display language
    // The coordinator does the right image selection
    func showImage(imageTitle: String?, imageData: ProductImageData?) {
        let childViewController = ImageViewController.instantiate()
        childViewController.coordinator = self
        childViewController.imageTitle = imageTitle
        childViewController.imageData = imageData
        viewController?.present(childViewController, animated: true, completion: nil)
    }

    func showNutrientUnitSelector(nutrient: Nutrient?, unit: NutritionFactUnit?, anchoredOn button:UIButton) {
        let childViewController = SelectNutrientUnitViewController.instantiate()
        childViewController.coordinator = self
        childViewController.configure(nutrient: nutrient, unit: unit)
        presentAsPopOver(childViewController, at: button)
    }

    func showAddNutrientSelector(current nutrients:[String], anchoredOn button:UIButton) {
        let childViewController = AddNutrientViewController.instantiate()
        childViewController.coordinator = self
        childViewController.configure(existing: nutrients)
        presentAsFormSheet(childViewController)
    }

    func showNutritionFactsTableStyleSelector(selected nutritionFactsTableStyle: NutritionFactsLabelStyle?, anchoredOn button:UIButton) {
        let childViewController = SelectNutritionFactsTableStyleTableViewController.instantiate()
        childViewController.coordinator = self
        childViewController.configure(selected:nutritionFactsTableStyle)
        presentAsFormSheet(childViewController)
    }
    
    func showLanguageSelector(with currentLanguageCode: String?, atAnchor button: UIButton) {
        let childViewController = SelectLanguageViewController.instantiate()
        childViewController.coordinator = self
        childViewController.configure(primaryLanguageCode: productPair?.primaryLanguageCode, currentLanguageCode: currentLanguageCode, languageCodes: productPair?.remoteProduct?.languageCodes)
        presentAsPopOver(childViewController, at: button)
    }

    private func refresh() {
        coordinatorViewController?.refreshProduct()
    }
}

extension NutrientsCoordinator: ImageViewControllerCoordinator {
    
    func imageViewController(_ sender:ImageViewController, tapped barButton:UIBarButtonItem) {
        sender.dismiss(animated: true, completion: nil)
    }
}

extension NutrientsCoordinator: SelectNutritionFactsTableStyleTableViewControllerCoordinator {
    func selectNutritionFactsTableStyleTableViewController(_ sender: SelectNutritionFactsTableStyleTableViewController, selected style: NutritionFactsLabelStyle?) {
        coordinatorViewController?.setNutritionFactsTableStyle(to: style)
        sender.dismiss(animated: true, completion: nil)
    }
    
    func selectNutritionFactsTableStyleTableViewControllerDidCancel(_ sender: SelectNutritionFactsTableStyleTableViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
    
    
}

extension NutrientsCoordinator: SelectNutrientUnitViewControllerCoordinator {
    
    func selectNutrientUnitViewController(_ sender: SelectNutrientUnitViewController, nutrient: Nutrient?, unit: NutritionFactUnit?) {
        productPair?.update(nutrient:nutrient, unit:unit)
        sender.dismiss(animated: true, completion: nil)
    }

    func selectNutrientUnitViewControllerDidCancel(_ sender:SelectNutrientUnitViewController) {
        sender.dismiss(animated: true, completion: nil)
    }

}

extension NutrientsCoordinator : AddNutrientViewControllerCoordinator {    
    
    func addNutrientViewController(_ sender:AddNutrientViewController, add nutrientTuple:(Nutrient, String, NutritionFactUnit)?) {
        if let newNutrientTuple = nutrientTuple {
                var newNutrient = NutritionFactItem()
                newNutrient.nutrient = newNutrientTuple.0
                newNutrient.itemName = newNutrientTuple.1
                newNutrient.unit = newNutrientTuple.2
                productPair?.update(fact: newNutrient)
        }
        coordinatorViewController?.refreshProduct()
        sender.dismiss(animated: true, completion: nil)
    }

    func addNutrientViewControllerDidCancel(_ sender:AddNutrientViewController) {
        sender.dismiss(animated: true, completion: nil)
    }

}

extension NutrientsCoordinator: SelectLanguageViewControllerCoordinator {
    
    public func selectLanguageViewController(_ sender:SelectLanguageViewController, selected languageCode:String?) {
        coordinatorViewController?.currentLanguageCode = languageCode
        sender.dismiss(animated: true, completion: nil)
    }
    
    public func selectLanguageViewControllerDidCancel(_ sender:SelectLanguageViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
}
