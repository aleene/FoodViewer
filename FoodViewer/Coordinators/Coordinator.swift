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
public protocol Coordinator: class {
    var viewController: UIViewController? { get set }
    /// The services that the coordinator can use
    //var services: Services { get }
    
    /// The array containing any child Coordinators
    var childCoordinators: [Coordinator] { get set }

/**
Informs the coordinator that the viewController disappeared

For this presentation style no other configuration is possible.
 - Important:
     This must be implemented by all viewControllers that have a coordinator in viewDidDisappear(animated:)
 - parameters:
    - viewController: the viewController that will be presented.
*/
    func viewControllerDidDisappear(_ sender:UIViewController)
/**
Present the viewController as PopOver.

For this presentation style no other configuration is possible.
 - parameters:
    - viewController: the viewController that will be presented.
    - anchor: a button that will be used as popOver anchor
*/
    func presentAsPopOver(_ viewController: UIViewController, at anchor:UIButton)
    
/**
Present the viewController as FormSheet.

For this presentation style no other configuration is possible.
 - parameters:
    - viewController: the viewController that will be presented.
*/
    func presentAsFormSheet(_ viewController: UIViewController)
}

public extension Coordinator {
    
    func viewControllerDidDisappear(_ sender:UIViewController) {
        guard !childCoordinators.isEmpty else { return }
        guard let index = childCoordinators.firstIndex(where: ({ $0.viewController === sender }) ) else { return }
        childCoordinators.remove(at: index)
    }

    func presentAsPopOver(_ viewController: UIViewController, at anchor:UIButton) {
        viewController.modalPresentationStyle = .popover
        guard self.viewController != nil else { return }
        if let ppc = viewController.popoverPresentationController {
            // set the main language button as the anchor of the popOver
            ppc.permittedArrowDirections = .right
            // I need the button coordinates in the coordinates of the current controller view
            let anchorFrame = anchor.convert(anchor.bounds, to: self.viewController?.view)
            ppc.sourceRect = anchorFrame // bottomCenter(anchorFrame)
            ppc.sourceView = self.viewController!.view
            if self.viewController is UIPopoverPresentationControllerDelegate {
                ppc.delegate = (self.viewController as! UIPopoverPresentationControllerDelegate)
            }
            viewController.preferredContentSize = viewController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            self.viewController?.present(viewController, animated: true, completion: nil)
        }
    }

    func presentAsFormSheet(_ viewController: UIViewController) {
        viewController.modalPresentationStyle = .formSheet
        self.viewController?.present(viewController, animated: true, completion: nil)
    }
    
    func presentAsPush(_ viewController: UIViewController) {
        //viewController.modalPresentationStyle = .overFullScreen
        if let nav = self.viewController?.navigationController {
            nav.pushViewController(viewController, animated: true)
        }
    }

}
