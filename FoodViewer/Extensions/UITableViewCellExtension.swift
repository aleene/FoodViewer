//
//  UITableViewCellExtension.swift
//  FoodViewer
//
//  Created by arnaud on 22/01/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

extension UITableViewCell {
    class var identifier: String {
        String(describing:self)
    }
}
