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
    
    var uploader: String?
    
    var imageDate: Double?

    var usedIn: [(String,ImageTypeCategory)] = []
    
    mutating func reset() {
        let cache = Shared.imageCache
        if let validDisplay = display {
            validDisplay.fetchResult = nil
            if let validURL = validDisplay.url {
                cache.remove(key: validURL.absoluteString)
            }
        }
        if let validDisplay = small {
            validDisplay.fetchResult = nil
            if let validURL = validDisplay.url {
                cache.remove(key: validURL.absoluteString)
            }
        }
        if let validDisplay = thumb {
            validDisplay.fetchResult = nil
            if let validURL = validDisplay.url {
                cache.remove(key: validURL.absoluteString)
            }
        }
        if let validDisplay = original {
            validDisplay.fetchResult = nil
            if let validURL = validDisplay.url {
                cache.remove(key: validURL.absoluteString)
            }
        }
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
    
/** The imageFetchResult of the largest image (if successful), otherwise the thumbnail
 **/
    public var largestOrThumb: ImageFetchResult? {
        if let validOriginalFetchResult = original?.fetchResult {
            switch validOriginalFetchResult {
            case .success:
                return validOriginalFetchResult
            default: break
            }
        } else {
            _ = original?.fetch()
        }
        if let validThumbFetchResult = thumb?.fetchResult {
            switch validThumbFetchResult {
            case .success:
                return validThumbFetchResult
            default: break
            }
        } else {
            _ = thumb?.fetch()
        }
        return nil
    }

// MARK: - initialisers
    
    init() {
        display = nil
        small = nil
        thumb = nil
        original = nil
        usedIn = []
    }
    
    init(for barcode:BarcodeType, and key: String) {
        self.init()
        thumb = ProductImageData.init(barcode:barcode, key:key, size:.thumb)
        small = ProductImageData.init(barcode:barcode, key:key, size:.small)
        display = ProductImageData.init(barcode:barcode, key:key, size:.display)
        original = ProductImageData.init(barcode:barcode, key:key, size:.original)
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
        
    func flush() {
        // This will remove the stored images and set the fetchResult to flushed
        // The images will be retrieved again from disk or internet
        display?.fetchResult = nil // 400
        small?.fetchResult = nil // 200
        thumb?.fetchResult = nil // 100
        original?.fetchResult = nil // any
    }

}
