//
//  ProductImageData.swift
//  FoodViewer
//
//  Created by arnaud on 06/02/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

public class ProductImageData {
    
    public struct Notification {
        static let ImageSizeCategoryKey = "ProductImageData.Notification.ImageSizeCategory.Key"
        static let ImageTypeCategoryKey = "ProductImageData.Notification.ImageCategory.Key"
        static let BarcodeKey = "ProductImageData.Notification.Barcode.Key"
    }
    

    var url: URL? = nil
    
    var fetchResult: ImageFetchResult? = nil {
        didSet {
            if fetchResult != nil {
                switch fetchResult! {
                case .success(let data):
                    // encode imageSize, imageType and barcode
                    var userInfo: [String:Any] = [:]
                    userInfo[Notification.ImageSizeCategoryKey] = imageSize().rawValue
                    
                    userInfo[Notification.ImageTypeCategoryKey] = imageType().rawValue
                    if let validBarcode = barcode() {
                        userInfo[Notification.BarcodeKey] = validBarcode
                    } else {
                        userInfo[Notification.BarcodeKey] = "Dummy barcode"
                    }

                    NotificationCenter.default.post(name: .ImageSet, object: nil, userInfo: userInfo)
                    image = UIImage(data:data)
                default:
                    break
                }
            }
        }
    }

    var image: UIImage? = nil
    
    init() {
        url = nil
        fetchResult = nil
    }
    
    init(url: URL) {
        self.url = url
        fetchResult = nil
    }
    
    init(image: UIImage) {
        self.url = nil
        fetchResult = nil
        self.image = image
    }
    
    func fetch() -> ImageFetchResult? {
        if fetchResult == nil {
            fetchResult = .loading
            // launch the image retrieval
            fetchResult?.retrieveImageData(url) { (fetchResult:ImageFetchResult?) in
                self.fetchResult = fetchResult
            }
        }
        return fetchResult
    }
    
    func reset() {
        fetchResult = nil
    }
    
    func type() -> ProductType? {
        if let validUrl = url {
            if validUrl.absoluteString.contains(ProductType.food.rawValue) {
                return .food
            } else if validUrl.absoluteString.contains(ProductType.petFood.rawValue) {
                return .petFood
            } else if validUrl.absoluteString.contains(ProductType.beauty.rawValue) {
                return .beauty
            }
        }
        return nil
    }
    private func imageType() -> ImageTypeCategory {
        guard url != nil else { return .unknown }
        
        if url!.absoluteString.contains(OFF.URL.ImageType.Front) {
            return .front
        } else if url!.absoluteString.contains(OFF.URL.ImageType.Ingredients) {
            return .ingredients
        } else if url!.absoluteString.contains(OFF.URL.ImageType.Nutrition) {
            return .nutrition
        }
        return .unknown
    }
    
    private func imageSize() -> ImageSizeCategory {
        guard url != nil else { return .unknown }
        
        if url!.absoluteString.contains(OFF.URL.ImageSize.Thumb) {
            return .thumb
        } else if url!.absoluteString.contains(OFF.URL.ImageSize.Medium) {
            return .small
        } else if url!.absoluteString.contains(OFF.URL.ImageSize.Large) {
            return .large
        }
        return .unknown
    }

    private func barcode() -> String? {
        // decode the url to get the barcode
        guard url != nil else { return nil }
        // let separator = OFF.URL.Divider.Slash
        let elements = url!.absoluteString.characters.split{ $0 == "/" }.map(String.init)
        // https://static.openfoodfacts.org/images/products/327/019/002/5337/ingredients_fr.27.100.jpg
        if elements.count >= 8 {
            return elements[4] + elements[5] + elements[6] + elements[7]
        } else {
            return "No valid barcode"
        }
    }

}

// Definition:
extension Notification.Name {
    static let ImageSet = Notification.Name("ProductImageData.Notification.ImageSet")
}

