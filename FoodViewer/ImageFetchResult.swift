//
//  ImageFetchResult.swift
//  FoodViewer
//
//  Created by arnaud on 05/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//
//  The function of this enum is to start a network call in order to retrieve an image based on an url

import Foundation

enum ImageFetchResult {
    case available
    case success(Data)
    case loading
    case loadingFailed(Error)
    case response(HTTPURLResponse)
    case noResponse
    case noData
    case noImageAvailable
    case uploading
    
    public var description: String {
        switch self {
        case .available: return TranslatableStrings.ImageIsAvailable
        case .success: return TranslatableStrings.DataIsLoaded
        case .loading: return TranslatableStrings.ImageIsBeingLoaded
        case .loadingFailed: return TranslatableStrings.ImageLoadingHasFailed
        case .noData: return TranslatableStrings.ImageWasEmpty
        case .response: return TranslatableStrings.ResponseReceived
        case .noImageAvailable: return TranslatableStrings.NoImageAvailable
        case .noResponse: return TranslatableStrings.NoResponse
        case .uploading: return TranslatableStrings.UploadingImage
        }
    }

}
