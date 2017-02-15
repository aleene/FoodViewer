//
//  ProductImageSize.swift
//  FoodViewer
//
//  Created by arnaud on 06/02/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

struct ProductImageSize {
    var display:[String:ProductImageData] = [:]
    var small: [String:ProductImageData] = [:]
    var thumb: [String:ProductImageData] = [:]
 
    mutating func reset() {
        for pair in display {
            pair.value.fetchResult = nil
        }
        for pair in small {
            pair.value.fetchResult = nil
        }
        for pair in thumb {
            pair.value.fetchResult = nil
        }

    }
}
