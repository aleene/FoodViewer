//
//  NutritionLevelQuantity.swift
//  FoodViewer
//
//  Created by arnaud on 18/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

enum NutritionLevelQuantity {
    case Low
    case Moderate
    case High
    case Undefined
    
    mutating func string(s:String?) {
        if let newString = s {
            if newString == "high" {
                self = .High
            } else if newString == "moderate" {
                self = .Moderate
            } else if newString == "low" {
                self = .Low
            } else {
                self = .Undefined
            }
        } else {
            self = .Undefined
        }
    }
}
