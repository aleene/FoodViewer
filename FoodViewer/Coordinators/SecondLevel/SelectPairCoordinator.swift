//
//  SelectPairCoordinator.swift
//  FoodViewer
//
//  Created by arnaud on 19/02/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

/**
This class coordinates the viewControllers initiated by `SelectPairCoordinator` and their corresponding interaction flow.
 
 The interaction flow between the parent coordinator and this coordinator is handled by the parent coordinator through a extension. This interaction flow is defined as a protocol in the viewController coordinated by THIS class.
 
 - Important
 The parent coordinator must be passed on to the coordinated viewController and will be used for any protocol methods.

Variables:
 - `parentCoordinator`: the parent is the owner of this coordinator and the root for the associated viewController;
 - `childCoordinators`: the other coordinators that are required in child viewControllers;
 - `viewController`: the `SelectPairViewController` that is managed;
 
Functions:
  - `init(with:)` the initalisation method of this coordinator AND the corresponding viewController.
 
 - parameters:
    - with:  the parent Coordinator;
 
  - `init(with:original:allPairs:multipleSelectionIsAllowed:showOriginalsAsSelected:tag:assignedHeader:unAssignedHeader:undefinedText:)` the convenience init method, which sets up the corresponding viewController.
 
 - parameters:
    - with: the parent coordinator;
    - original: the pairs that have already been selected;
    - allPairs: the pairs from which one can select;
    - multipleSelectionIsAllowed: the user can select multiple pairs;
    - showOriginalsAsSelected: the already selected pairs will be shown as selected;
    - tag: an identifier
    - assignedHeader: the header for the section with assigned pairs;
    - unAssignedHeader: the header for the section with UNassigned pairs;
    - undefinedText: the text to show when a pair is undefined;

 - `show()` - show the managed viewController from the parent viewController view stack. The viewController is push on a navigation controller.

 Managed viewControllers:
 - none
*/
final class SelectPairCoordinator: Coordinator {
        
    weak var parentCoordinator: Coordinator? = nil
    /// The child coordinators currently managed by this coordinator. If the child viewcontroller dispaaears this coordinator is no longer needed.
    var childCoordinators: [Coordinator] = []

    var viewController: UIViewController? = nil
        
    var coordinatorViewController: SelectPairViewController? {
        self.viewController as? SelectPairViewController
    }

    init(with coordinator: Coordinator?) {
        self.parentCoordinator = coordinator
        self.viewController = SelectPairViewController.instantiate()
        if let protocolCoordinator = coordinator as? SelectPairCoordinatorProtocol {
            self.coordinatorViewController?.protocolCoordinator = protocolCoordinator
        } else {
            print("SelectPairCoordinator: coordinator does not conform to protocol")
        }
    }
    
    // pass on the data
    convenience init(with coordinator: Coordinator?, original: [String]?,
                   allPairs: [Language],
                   multipleSelectionIsAllowed: Bool,
                   showOriginalsAsSelected: Bool,
                   tag: Int,
                   assignedHeader: String,
                   unAssignedHeader: String,
                   undefinedText: String) {
        self.init(with: coordinator)
        self.coordinatorViewController?.configure(
            original: original,
            allPairs: allPairs,
            multipleSelectionIsAllowed: multipleSelectionIsAllowed,
            showOriginalsAsSelected: showOriginalsAsSelected,
            tag: tag,
            assignedHeader: assignedHeader,
            unAssignedHeader: unAssignedHeader,
            undefinedText: undefinedText)
    }

    func show() {
        self.parentCoordinator?.presentAsFormSheet(self.viewController)
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

