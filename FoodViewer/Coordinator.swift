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

    /// Function used to tell the coordinator that a viewController disappeared.
    func viewControllerDidDisappear(_ sender:UIViewController)
    
}

public extension Coordinator {
    
    func viewControllerDidDisappear(_ sender:UIViewController) {
        guard !childCoordinators.isEmpty else { return }
        guard let index = childCoordinators.firstIndex(where: ({ $0.viewController === sender }) ) else { return }
        childCoordinators.remove(at: index)
    }

}
