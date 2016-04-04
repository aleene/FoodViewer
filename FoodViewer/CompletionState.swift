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
    var photosValidatedComplete = Status()
    var productNameComplete = Status()
    var brandsComplete = Status()
    var quantityComplete = Status()
    var packagingComplete = Status()
    var categoriesComplete = Status()
    var nutritionFactsComplete = Status()
    var photosUploadedComplete = Status()
    var ingredientsComplete = Status()
    var expirationDateComplete = Status()
    
    func completionPercentage() -> Int {
        let val = Int(photosValidatedComplete.value) * 10 +
            Int(productNameComplete.value) * 10 +
            Int(brandsComplete.value) * 10 +
            Int(quantityComplete.value) * 10 +
            Int(packagingComplete.value) * 10 +
            Int(categoriesComplete.value) * 10 +
            Int(nutritionFactsComplete.value) * 10 +
            Int(photosUploadedComplete.value) * 10 +
            Int(ingredientsComplete.value) * 10 +
            Int(expirationDateComplete.value) * 10
        return val
    }
    
    func completionPercentageAsDouble() -> Double {
        return Double(completionPercentage()) / 100.0
    }
}