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
    case notPossible
    case failure(String)
    
    var description: String {
        switch self {
        case .success: return "ProductUpdateStatus: update succeeded"
        case .notPossible: return "ProductUpdateStatus: update not possible at the moment"
        case .failure: return "ProductUpdateStatus: update failed"
        }
    }
}
