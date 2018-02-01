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
    // The images come in 4 sizes
    var display: ProductImageData? = nil // 400
    var small: ProductImageData? = nil // 200
    var thumb: ProductImageData? = nil // 100
    var original: ProductImageData? = nil // any
    var usedIn: [(String,ImageTypeCategory)] = []
    
    mutating func reset() {
        if display != nil { display!.fetchResult = nil }
        if small != nil { small!.fetchResult = nil }
        if thumb != nil { thumb!.fetchResult = nil }
        if original != nil { original!.fetchResult = nil }
    }
    
    var largest: ProductImageData? {
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
    
    var date: Date? {
        if original?.date != nil {
            return original!.date
        } else if display?.date != nil {
            return display!.date
        } else if small?.date != nil {
            return small!.date
        } else {
            return thumb!.date
        }
    }

    
    func isSelectedAsIngredientsImage(for languageCode:String) -> Bool {
        return isSelected(for:.ingredients, in:languageCode)
    }
    
    func isSelectedAsFrontImage(for languageCode:String) -> Bool {
        return isSelected(for:.front, in:languageCode)
    }
    func isSelectedAsNutritionImage(for languageCode:String) -> Bool {
        return isSelected(for:.nutrition, in:languageCode)
    }

    func isSelected(for type:ImageTypeCategory, in languageCode:String) -> Bool {
        for value in usedIn {
            let (usageLC, usageType) = value
            if  usageLC == languageCode && usageType == type {
                return true
            }
        }
        return false
    }

}
