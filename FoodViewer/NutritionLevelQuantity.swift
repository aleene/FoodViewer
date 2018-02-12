//
//  NutritionLevelQuantity.swift
//  FoodViewer
//
//  Created by arnaud on 18/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

public enum NutritionLevelQuantity {
    case low
    case moderate
    case high
    case undefined
    
    public mutating func string(_ s:String?) {
        if let newString = s {
            if newString == "high" {
                self = .high
            } else if newString == "moderate" {
                self = .moderate
            } else if newString == "low" {
                self = .low
            } else {
                self = .undefined
            }
        } else {
            self = .undefined
        }
    }
    
    public init() {
        self = .undefined
    }
    
    static func value(for offProductNutrientLevel:OFFProductNutrientLevelValue?) -> NutritionLevelQuantity {
        guard let validLevel = offProductNutrientLevel else { return .undefined }
        switch validLevel {
        case .low:
            return .low
        case .moderate:
            return .moderate
        case .high:
            return .high
        }
    }
}
