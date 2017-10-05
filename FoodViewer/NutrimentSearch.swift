//
//  NutrimentSearch.swift
//  FoodViewer
//
//  Created by arnaud on 01/10/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

struct NutrimentSearch {
    var key: String = "" // Use the Nutrients.plist keys for this (without the en:-prefix)
    var searchOperator: Operator = .equal
    var value: Double = 0.0
    var unit: NutritionFactUnit = .None
    var name: String = ""
    
    // # Operator
    //      lt # less than
    //      lte # less than or equal
    //      gt # greater than
    //      gte # greater than or equal
    //      eq # equal to
    
    enum Operator: String {
        case lessThan = "<"
        case lessThanOrEqual = "<="
        case equal = "=="
        case greaterThan = ">"
        case greaterThanOrEqual = ">="
    }

}
