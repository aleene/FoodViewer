//
//  ProductUpdateStatus.swift
//  FoodViewer
//
//  Created by arnaud on 29/09/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

enum ProductUpdateStatus {
    
    case success(String)
    case failure(String)
    
    func description() -> String {
        switch self {
        case .success: return NSLocalizedString("Product update succeeded", comment: "Where do I use this?")
        case .failure: return NSLocalizedString("Product update failed", comment: "Where do I use this?")
        }
    }
}
