//
//  ProductImageSize.swift
//  FoodViewer
//
//  Created by arnaud on 06/02/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

struct ProductImageSize {
    
// MARK: - public variables
    
    // The selected images for a specific languageCode. 
    // The images come in 4 sizes
    public var display: ProductImageData? = nil // 400
    public var small: ProductImageData? = nil // 200
    public var thumb: ProductImageData? = nil // 100
    public var original: ProductImageData? = nil // any
    
    public var uploader: String?
    
    public var imageDate: Double?

    /// Lists where this image has been used as selected image
    public var usedIn: [ImageTypeCategory] = []
    
    /// The image data of the largest image available
    public var largest: ProductImageData? {
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
    
    // initialises the imageSet based on the url of a selected image
    init(selectedURL: URL) {
        
        /* I tried to be smart, but that did not work out
         I am not able to translate the url offered by robotoff to an original image.
         The selectedURL might not contain info on the original image
        thumb = ProductImageData(url: selectedURL.OFFthumbImageURL)
        small = ProductImageData(url: selectedURL.OFFsmallImageURL)
        display = ProductImageData(url: selectedURL.OFFdisplayImageURL)
        original = ProductImageData(url: selectedURL.OFForiginalImageURL)
        */
        original = ProductImageData(url: selectedURL)
        
        if let imageTypeCategory = selectedURL.OFFimageType {
            usedIn.append(imageTypeCategory)
        }
    }

// MARK: - public functions
        
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
        
    public func isSelectedAsIngredientsImage(languageCode:String) -> Bool {
        return isSelected(imageType: .ingredients(languageCode))
    }
    
    public func isSelectedAsFrontImage(languageCode:String) -> Bool {
        return isSelected(imageType: .front(languageCode))
    }
    
    public func isSelectedAsNutritionImage(languageCode:String) -> Bool {
        return isSelected(imageType: .nutrition(languageCode))
    }

    public func isSelectedAsPackagingImage(languageCode:String) -> Bool {
        return isSelected(imageType: .packaging(languageCode))
    }

    public func isSelected(imageType: ImageTypeCategory) -> Bool {
        for imageTypeCategory in usedIn {
            if imageTypeCategory ~= imageType {
                return true
            }
        }
        return false
    }
        
    public func flush() {
        // This will remove the stored images and set the fetchResult to flushed
        // The images will be retrieved again from disk or internet
        display?.fetchResult = nil // 400
        small?.fetchResult = nil // 200
        thumb?.fetchResult = nil // 100
        original?.fetchResult = nil // any
    }

}
