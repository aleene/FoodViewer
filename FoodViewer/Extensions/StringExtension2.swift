//
//  StringExtension2.swift
//  FoodViewer
//
//  Created by arnaud on 18/03/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation

extension String {
    var floatValue: Float? {
        let nf = NumberFormatter()
        nf.decimalSeparator = "."
        if let result = nf.number(from: self) {
            return result.floatValue
        } else {
            nf.decimalSeparator = ","
            if let result = nf.number(from: self) {
                return result.floatValue
            }
        }
        return nil
    }

}
