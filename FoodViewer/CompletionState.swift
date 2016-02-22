//
//  CompletionState.swift
//  FoodViewer
//
//  Created by arnaud on 18/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

// completion states parameters
struct CompletionState {
    var photosValidatedComplete : Bool = false
    var productNameComplete : Bool = false
    var brandsComplete: Bool = false
    var quantityComplete: Bool = false
    var packagingComplete: Bool = false
    var categoriesComplete: Bool = false
    var nutritionFactsComplete: Bool = false
    var photosUploadedComplete: Bool = false
    var ingredientsComplete: Bool = false
    var expirationDateComplete: Bool = false
    
    func completionPercentage() -> Int {
        return Int(photosValidatedComplete) * 10 +
            Int(productNameComplete) * 10 +
            Int(brandsComplete) * 10 +
            Int(quantityComplete) * 10 +
            Int(packagingComplete) * 10 +
            Int(categoriesComplete) * 10 +
            Int(nutritionFactsComplete) * 10 +
            Int(photosUploadedComplete) * 10 +
            Int(ingredientsComplete) * 10 +
            Int(expirationDateComplete) * 10
    }
}