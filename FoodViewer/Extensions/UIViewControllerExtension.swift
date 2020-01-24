//
//  UIViewControllerExtension.swift
//  FoodViewer
//
//  Created by arnaud on 22/01/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

extension UIViewController {
    /// Returns a String representation of the class
    class var identifier: String {
        String(describing:self)
    }

    // Defines a standard identifier for a Segue
    // from viewController identifier + to viewController identifier
    func segueIdentifier<T: UIViewController>(to viewControllerType: T.Type) -> String {
        return String(describing:type(of: self).self) + "." + String(describing:viewControllerType)
    }

    // Defines a standard identifier for a Cell
    // tableViewCell identifier + viewController identifier
    func cellIdentifier<T: UITableViewCell>(for cellType: T.Type) -> String {
        return String(describing:cellType) + "." + String(describing:type(of: self).self)
    }
}
