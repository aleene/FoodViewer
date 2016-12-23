//
//  ColorScheme.swift
//  ManagedTagListView
//
//  Created by arnaud on 17/12/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

public struct ColorScheme {
    var textColor: UIColor
    var backgroundColor: UIColor
    var borderColor: UIColor
    
    init() {
        textColor  = .white
        backgroundColor = .blue
        borderColor = .blue
    }
    
    init(text textColor: UIColor, background backgroundColor: UIColor, border borderColor: UIColor) {
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
    }
    
}
