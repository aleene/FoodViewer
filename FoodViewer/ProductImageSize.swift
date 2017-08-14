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
    var display: ProductImageData? = nil
    var small: ProductImageData? = nil
    var thumb: ProductImageData? = nil
    var original: ProductImageData? = nil
    var containsBarcode = false
    var suppliesFront = false
    var suppliesNutrition = false
    var suppliesIngredients = false
 
    mutating func reset() {
        if display != nil { display!.fetchResult = nil }
        if small != nil { small!.fetchResult = nil }
        if thumb != nil { thumb!.fetchResult = nil }
        if original != nil { original!.fetchResult = nil }
    }
    
    func largest() -> ProductImageData? {
        if original != nil {
            return original
        } else if display != nil {
            return display
        } else if small != nil {
            return small
        } else {
            return thumb
        }
    }
}
