//
//  Coordinator.swift
//  FoodViewer
//
//  Created by arnaud on 07/02/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

/** The `Coordinator` protocol, which manages the flow of a `UIViewController`.
 
The coordinator manages the flow of a single viewController. Any action that the viewController can not handle, will passed onto its coordinators by means of a protocol defined by the viewController.
 
**Parameters** :
    - `childCoordinators` : the coordinators that are initiated by this coordinator.
 
**Functions** :
    - `viewControllerDidDisappear()` : to inform the coordinator that a viewController disappeared. This allows the coordinator to do some clean up.

**Usage** :
 - Set the Storyboard ID of the ViewController in Storyboard the same as class name.
 - Define an `init(with:)`
 - Define a `showChildViewController()` function, which will setup and present the child viewController
 - Define a dedicated coordinator for the childViewController. This is *optional* and only needed if the childViewController needs to initate its own (grand-)children.
 - Define a child Coordinator-protocol for the childViewController. This protocol has functions for unwinds and other actions that the child can not perform and need to be handled by its coordinator.
 - Create a Coordinator variable in the child that conforms to the Coordinator and child-Coordinator protocol
 - Have the coordinator adhere to the Coordinate-protocol defined by the child.
 - In the viewDidDisappear() of the child, call viewControllerDidDisappear() of the
 */
public protocol Coordinator: AnyObject {
    var viewController: UIViewController? { get set }
    
    var parentCoordinator: Coordinator? { get set }
    
    /// The child coordinator currently managed by this coordinator. If the child viewcontroller dispaaears this coordinator is no longer needed.
    var childCoordinators: [Coordinator] { get set }

    /// init with a reference to the coordinator that initiated this coordinator. If it is nil, there is no parent
    init(with coordinator:Coordinator?)
    
    /// show the viewController managed by the coordinator
    func show()
    
/**
    Informs the parent coordinator that the coordinator can disappear.
     
This should be called when the coordinator no longer has any child coordinators AND when its managed viewController has disappeared.
 - Important:
This must be implemented by all coordinators.
- parameters:
    - coordinator: the coordinator that can disappear.
*/
    func canDisappear(_ coordinator:Coordinator)
/**
The viewController informs its owner that it has disappeared
 - Important:
This must be implemented by all viewControllers that have a coordinator in viewDidDisappear(animated:)
 - parameters:
    - viewController: the viewController that is disappeared.
*/
    func viewControllerDidDisappear(_ sender: UIViewController)
}

public extension Coordinator {
    
    /// The viewController informs its owner that it has disappeared
    func viewControllerDidDisappear(_ sender: UIViewController) {
        self.viewController = nil
        informParent()
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
    /**
    Present the viewController as PopOver.

    For this presentation style no other configuration is possible.
     - parameters:
        - viewController: the viewController that will be presented.
        - anchor: a button that will be used as popOver anchor
    */
    func presentAsPopOver(_ viewController: UIViewController?, at anchor:UIButton?) {
        guard let validViewController = viewController else { return }
        validViewController.modalPresentationStyle = .popover
        if let ppc = validViewController.popoverPresentationController {
            // set the main language button as the anchor of the popOver
            ppc.permittedArrowDirections = .right
            if let validAnchor = anchor {
                // I need the button coordinates in the coordinates of the current controller view
                let anchorFrame = validAnchor.convert(validAnchor.bounds, to: self.viewController?.view)
                ppc.sourceRect = anchorFrame // bottomCenter(anchorFrame)
            }
            ppc.sourceView = self.viewController!.view
            if self.viewController is UIPopoverPresentationControllerDelegate {
                ppc.delegate = (self.viewController as! UIPopoverPresentationControllerDelegate)
            }
            validViewController.preferredContentSize = validViewController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            self.viewController?.present(validViewController, animated: true, completion: nil)
        }
    }
    
    /**
    Present the viewController as FormSheet.

    For this presentation style no other configuration is possible.
     - parameters:
        - viewController: the viewController that will be presented.
    */
    func presentAsFormSheet(_ viewController: UIViewController?) {
        guard let validViewController = viewController else { return }
        validViewController.modalPresentationStyle = .formSheet
        self.viewController?.present(validViewController, animated: true, completion: nil)
    }
    
    /*
    func presentAsPush(_ viewController: UIViewController?) {
        guard let validViewController = viewController else { return }
        //viewController.modalPresentationStyle = .overFullScreen
        if let nav = self.viewController?.navigationController {
            nav.pushViewController(validViewController, animated: true)
        }
    }
 */

}
