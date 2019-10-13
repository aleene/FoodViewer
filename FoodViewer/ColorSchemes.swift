//
//  ColorSchemes.swift
//  FoodViewer
//
//  Created by arnaud on 21/12/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

struct ColorSchemes {
    static let normal = ColorScheme.init(text: .white, background: .systemGreen, border: .systemGreen)
    static let none = ColorScheme.init(text: .white, background: .systemOrange, border: .systemOrange)
    static let removable = ColorScheme.init(text: .green, background: .white, border: .green)
    static let error = ColorScheme.init(text: .white, background: .systemRed, border: .systemRed)
}
