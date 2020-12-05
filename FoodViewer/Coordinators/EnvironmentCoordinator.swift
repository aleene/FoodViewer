//
//  EnvironmentCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 16/10/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

final class EnvironmentCoordinator: Coordinator {

    weak var parentCoordinator: Coordinator? = nil
      
    var childCoordinators: [Coordinator] = []
  
    var viewController: UIViewController? = nil
    
    weak private var productPair: ProductPair? = nil
    
    private var coordinatorViewController: EnvironmentTableViewController? {
        self.viewController as? EnvironmentTableViewController
    }
    
    init(with coordinator: Coordinator?) {
        self.viewController = EnvironmentTableViewController.instantiate()
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
    
    /// Show the forest footprint data details
    func showForestFootprint(forestFootprint: ForestFootprint) {
        let coordinator = ForestFootprintCoordinator(with: self, forestFootprint: forestFootprint)
        self.childCoordinators.append(coordinator)
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


extension EnvironmentCoordinator: ImageCoordinatorProtocol {
    
    func imageViewController(_ sender:ImageViewController, tapped barButton:UIBarButtonItem) {
        sender.dismiss(animated: true, completion: nil)
    }
}

extension EnvironmentCoordinator: ForestFootprintCoordinatorProtocol {
    
    func forestFootprintViewControllerDidTapDone(_ sender: ForestFootprintViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
}

// MARK: - SelectLanguageCoordinatorProtocol

extension EnvironmentCoordinator: SelectLanguageCoordinatorProtocol {
    
    public func selectLanguageViewController(_ sender:SelectLanguageViewController, selected languageCode:String?) {
        coordinatorViewController?.currentLanguageCode = languageCode
        sender.dismiss(animated: true, completion: nil)
    }
    
    public func selectLanguageViewControllerDidCancel(_ sender:SelectLanguageViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
}
