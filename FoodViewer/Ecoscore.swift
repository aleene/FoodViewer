//
//  Ecoscore.swift
//  FoodViewer
//
//  Created by arnaud on 27/11/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

public enum Ecoscore: String {
    case a
    case b
    case c
    case d
    case e
    case unknown
        
    var image: UIImage? {
        return UIImage(named: "ecoscore-\(self.rawValue)")
    }
}
    
