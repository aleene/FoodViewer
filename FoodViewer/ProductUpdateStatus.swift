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
    
    var description: String {
        switch self {
        case .success: return "Product update succeeded"
        case .failure: return "Product update failed"
        }
    }
}
