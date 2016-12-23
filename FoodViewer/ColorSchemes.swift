//
//  ColorSchemes.swift
//  FoodViewer
//
//  Created by arnaud on 21/12/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

struct ColorSchemes {
    static let normal = ColorScheme.init(text: .white, background: .green, border: .green)
    static let none = ColorScheme.init(text: .white, background: .orange, border: .orange)
    static let removable = ColorScheme.init(text: .green, background: .white, border: .green)
    static let error = ColorScheme.init(text: .white, background: .red, border: .red)
}
