//
//  ProductImageSize.swift
//  FoodViewer
//
//  Created by arnaud on 06/02/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

struct ProductImageSize {
    // The selected images for a specific languageCode. 
    // The images come in 3 sizes
    var display = ProductImageData()
    var small = ProductImageData()
    var thumb = ProductImageData()
    var hasBarcode = false
    var suppliesFront = false
    var suppliesNutrition = false
    var suppliesIngredients = false
 
    mutating func reset() {
            display.fetchResult = nil
            small.fetchResult = nil
            thumb.fetchResult = nil
    }
    
}
