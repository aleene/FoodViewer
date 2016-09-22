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
        var val = 0
        if photosValidatedComplete.value { val = val + 10 }
        if productNameComplete.value { val = val + 10 }
        if brandsComplete.value { val = val + 10 }
        if quantityComplete.value { val = val + 10 }
        if packagingComplete.value { val = val + 10 }
        if categoriesComplete.value { val = val + 10 }
        if nutritionFactsComplete.value { val = val + 10 }
        if photosUploadedComplete.value { val = val + 10 }
        if ingredientsComplete.value { val = val + 10 }
        if expirationDateComplete.value { val = val + 10 }
        return val
    }
    
    func completionPercentageAsDouble() -> Double {
        return Double(completionPercentage()) / 100.0
    }
}
