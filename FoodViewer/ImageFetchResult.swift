//
//  ImageFetchResult.swift
//  FoodViewer
//
//  Created by arnaud on 05/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

enum ImageFetchResult {
    case Success(NSData)
    case Loading
    case LoadingFailed(ErrorType)
    case NoData
    case NoImageAvailable
    
    func description() -> String {
        switch self {
        case .Success: return NSLocalizedString("Image is loaded", comment: "String presented in a tagView if the image has been loaded")
        case .Loading: return NSLocalizedString("Image is being loaded", comment: "String presented in a tagView if the image is currently being loaded")
        case .LoadingFailed: return NSLocalizedString("Image loading has failed", comment: "String presented in a tagView if the image loading has failed")
        case .NoData: return NSLocalizedString("Image was empty", comment: "String presented in a tagView if the image data contained no data")
        case .NoImageAvailable: return NSLocalizedString("No image available", comment: "String presented in a tagView if no image is available")
        }
    }
}