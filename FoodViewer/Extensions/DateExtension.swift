//
//  DateExtension.swift
//  FoodViewer
//
//  Created by arnaud on 26/10/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import Foundation

extension Date {
    
    public var ageInYears: Double? {
        return Date().timeIntervalSince(self) / (24 * 60 * 60 * 365.25)
    }

}
