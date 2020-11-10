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

    public var usedIn: [(String, ImageTypeCategory)] = []
    
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
    init(selectedURLString: String) {
        
        // Determine image size from url
        if selectedURLString.contains(".400.") {
            var string = selectedURLString.replacingOccurrences(of: ".400.", with: ".100.")
            thumb = ProductImageData(url: URL(string: string))
            small = ProductImageData(url: URL(string: selectedURLString.replacingOccurrences(of: ".400.", with: ".200.")))
            display = ProductImageData(url: URL(string: selectedURLString))
            string = selectedURLString.replacingOccurrences(of: ".400.", with: ".")
            original = ProductImageData(url: URL(string: string))

        } else if selectedURLString.contains(".200.") {
            thumb = ProductImageData(url: URL(string: selectedURLString.replacingOccurrences(of: ".200.", with: ".100.")))
            small = ProductImageData(url: URL(string: selectedURLString))
            display = ProductImageData(url: URL(string: selectedURLString.replacingOccurrences(of: ".200.", with: ".400.")))
            original = ProductImageData(url: URL(string: selectedURLString.replacingOccurrences(of: ".200.", with: ".")))

        } else if selectedURLString.contains(".100.") {
            thumb = ProductImageData(url: URL(string: selectedURLString))
            small = ProductImageData(url: URL(string: selectedURLString.replacingOccurrences(of: ".100.", with: ".200.")))
            display = ProductImageData(url: URL(string: selectedURLString.replacingOccurrences(of: ".100.", with: ".400.")))
            original = ProductImageData(url: URL(string: selectedURLString.replacingOccurrences(of: ".100.", with: ".")))

        } else {
            print("ProductImageSize:", selectedURLString)
        }
        
        // determine languageCode of image url
        let splits = selectedURLString.split(separator: "_")
        if splits.count == 2 {
            let fileSplits = splits[1].split(separator: ".")
            if fileSplits.count > 0 {
                let languageCode = String(fileSplits[0]) as String
                
                // determine imageType from url
                if selectedURLString.contains(ImageTypeCategory.front.description)  {
                    usedIn.append((languageCode, ImageTypeCategory.front))
                } else if selectedURLString.contains(ImageTypeCategory.ingredients.description)  {
                    usedIn.append((languageCode, ImageTypeCategory.ingredients))
                } else if selectedURLString.contains(ImageTypeCategory.nutrition.description)  {
                    usedIn.append((languageCode, ImageTypeCategory.nutrition))
                } else if selectedURLString.contains(ImageTypeCategory.packaging.description)  {
                    usedIn.append((languageCode, ImageTypeCategory.packaging))
                }
            }
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
        
    public func isSelectedAsIngredientsImage(for languageCode:String) -> Bool {
        return isSelected(for:.ingredients, in:languageCode)
    }
    
    public func isSelectedAsFrontImage(for languageCode:String) -> Bool {
        return isSelected(for:.front, in:languageCode)
    }
    
    public func isSelectedAsNutritionImage(for languageCode:String) -> Bool {
        return isSelected(for:.nutrition, in:languageCode)
    }

    public func isSelected(for type:ImageTypeCategory, in languageCode:String) -> Bool {
        for value in usedIn {
            let (usageLC, usageType) = value
            if  usageLC == languageCode && usageType == type {
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
