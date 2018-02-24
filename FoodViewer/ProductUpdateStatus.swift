//
//  ProductUpdateStatus.swift
//  FoodViewer
//
//  Created by arnaud on 29/09/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

enum ProductUpdateStatus {
    
    // The first string is the BarcodeString and is used as identification of the product
    case success(String, String)
    case images(String)
    case notPossible(String)
    case failure(String, String)
    
    var description: String {
        switch self {
        case .images: return "ProductUpdateStatus: images submitted for update"
        case .success: return "ProductUpdateStatus: update succeeded"
        case .notPossible: return "ProductUpdateStatus: update not possible at the moment"
        case .failure: return "ProductUpdateStatus: update failed"
        }
    }
}
