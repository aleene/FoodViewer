//
//  URLExtension.swift
//  FoodViewer
//
//  Created by arnaud on 05/02/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

extension URL {
    
    static func createDirectory(with name: String) -> URL? {
        let fileManager = FileManager.default
        if let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = directory.appendingPathComponent(name)
            if !fileManager.fileExists(atPath: filePath.path) {
                do {
                    try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    assert(true, "URLExtension: Not possible to create a directory")
                }
            } else {
                assert(true, "URLExtension: Not possible to create a directory")
            }
        }
        return nil
    }
    
// MARK: - OFF image url decompose functions
    
// example URL:
// https://static.openfoodfacts.org/images/products/500/015/940/4259/front_de.126.200.jpg
// https://static.openfoodfacts.org/images/products/500/015/940/4259/2.100.jpg
    
    /// decode the image ID from an OFF image URL
    var OFFimageID: String? {
        let slashSplits = self.absoluteString.split(separator: "/")
        guard let dotSplits = slashSplits.last?.split(separator: ".") else { return nil }
        switch dotSplits.count {
        case 2, 3:
            // 2.100.jpg
            return String(dotSplits[0])
        case 4:
            // front_de.126.200.jpg
            return String(dotSplits[1])
        default: return nil
        }
    }

    /// decode the image type from an OFF image URL
    var OFFimageType: ImageTypeCategory? {
        if self.absoluteString.contains(OFF.URL.ImageType.Front) {
            return .front
        } else if self.absoluteString.contains(OFF.URL.ImageType.Ingredients) {
            return .ingredients
        } else if self.absoluteString.contains(OFF.URL.ImageType.Nutrition) {
            return .nutrition
        }
        return .general
    }
    
    /// decode the barcode from an OFF image URL
    var OFFbarcode: String? {
        let elements = self.absoluteString.split(separator:"/").map(String.init)
        // https://static.openfoodfacts.org/images/products/327/019/002/5337/ingredients_fr.27.100.jpg
        if elements.count >= 8 {
            return elements[4] + elements[5] + elements[6] + elements[7]
        } else if elements.count == 6 {
            return elements[4]
        }
        return nil
    }
    
    /// decode the  languageCode from an OFF image url
    var OFFlanguageCode: String? {
        let splits = self.absoluteString.split(separator: "_")
        if splits.count == 2 {
            let fileSplits = splits[1].split(separator: ".")
            if fileSplits.count > 0 {
                return String(fileSplits[0])
            }
        }
        return nil
    }

    /// decode the image size from an OFF image URL
    var OFFimageSize: ImageSizeCategory? {
        let slashSplits = self.absoluteString.split(separator: "/")
        guard let dotSplits = slashSplits.last?.split(separator: ".") else { return nil }
        switch dotSplits.count {
        case 2:
            return .original
        case 3:
            switch String(dotSplits[1]) {
            case ImageSizeCategory.thumb.size:
                return .thumb
            case ImageSizeCategory.small.size:
                return .small
            case ImageSizeCategory.display.size:
                return .display
            default: break
            }
        case 4:
            switch String(dotSplits[2]) {
            case ImageSizeCategory.thumb.size:
                return .thumb
            case ImageSizeCategory.small.size:
                return .small
            case ImageSizeCategory.display.size:
                return .display
            default: break
            }
        default: break
        }
        return nil
    }

    /// converts an OFF image URL to a thumb image URL
    var OFFthumbImageURL: URL? {
        return OFFImageURL(for: .thumb)
    }
    

    /// Converts an OFF image URL to a small image URL
    var OFFsmallImageURL: URL? {
        return OFFImageURL(for: .small)
    }

    /// converts an OFF image URL to a display image URL
    var OFFdisplayImageURL: URL? {
        return OFFImageURL(for: .display)
    }

    /// converts an OFF image URL to a original image URL
    var OFForiginalImageURL: URL? {
        let slashSplits = self.absoluteString.split(separator: "/")
        let lastPart = slashSplits.last
        let firstPart = slashSplits.dropLast().joined(separator: "/")
        guard var dotSplits = lastPart?.split(separator: ".") else { return nil }
        switch dotSplits.count {
        case 2:
            // 2.jpg
            return self
        case 3:
            // 2.100.jpg
            dotSplits.remove(at: 1) // get rid of the image size
            let newURLString = firstPart + "/" + dotSplits.joined(separator: ".")
            return URL(string: newURLString)
        case 4:
            // front_de.126.200.jpg
            dotSplits.remove(at: 0) // get rid the selected image type
            dotSplits.remove(at: 1) // get rid of the image size
            let newURLString = firstPart + "/" + dotSplits.joined(separator: ".")
            return URL(string: newURLString)
        default: break
        }
        return nil
    }
    
    func OFFImageURL(for imageSize: ImageSizeCategory) -> URL? {
        let slashSplits = self.absoluteString.split(separator: "/")
        let lastPart = slashSplits.last
        let firstPart = slashSplits.dropLast().joined(separator: "/")
        guard let dotSplits = lastPart?.split(separator: ".") else { return nil }
        switch dotSplits.count {
        case 2:
            // 2.jpg
            var newURLString = firstPart
            newURLString += "/"
            newURLString += String(dotSplits.first!)
            newURLString +=  "."
            newURLString += imageSize.size
            newURLString += "."
            newURLString += String(dotSplits.last!)
            return URL(string: newURLString)
        case 3:
            // 2.100.jpg
            var dotSplitsString: [String] = dotSplits.map({ String($0) })
            dotSplitsString[1] = imageSize.size
            let newURLString = firstPart + "/" + dotSplitsString.joined(separator: ".")
            return URL(string: newURLString)
        case 4:
            // front_de.126.200.jpg
            var dotSplitsString: [String] = dotSplits.dropFirst().map({ String($0) })
            dotSplitsString[1] = imageSize.size
            let newURLString = firstPart + "/" + dotSplitsString.joined(separator: ".")
            return URL(string: newURLString)
        default: break
        }
        return nil
    }
    
    /// converts an OFF image URL into a product server type
    var productServertype: ProductType? {
        if self.absoluteString.contains(ProductType.food.rawValue) {
            return .food
        } else if self.absoluteString.contains(ProductType.petFood.rawValue) {
            return .petFood
        } else if self.absoluteString.contains(ProductType.beauty.rawValue) {
            return .beauty
        } else if self.absoluteString.contains(ProductType.product.rawValue) {
            return .product
        }
        return nil
    }

}
