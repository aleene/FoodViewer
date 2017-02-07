//
//  ProductImageData.swift
//  FoodViewer
//
//  Created by arnaud on 06/02/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

class ProductImageData {
    var url: URL? = nil
    var fetchResult: ImageFetchResult? = nil {
        didSet {
            if fetchResult != nil {
                // encode the url, so it can be determined if the receiver need to act on it.
                NotificationCenter.default.post(name: .ImageSet, object: nil)
            }
        }
    }

    var image: UIImage? {
        get {
            guard fetchResult != nil else { return nil}
            switch fetchResult! {
            case .success(let data):
                return UIImage(data:data)
            default:
                return nil
            }
        }
    }
    
    init() {
        url = nil
        fetchResult = nil
    }
    
    init(url: URL) {
        self.url = url
        fetchResult = nil
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
}

// Definition:
extension Notification.Name {
    static let ImageSet = Notification.Name("ProductImageData.Notification.ImageSet")
}

