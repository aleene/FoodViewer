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

    var rawValue: Int {
        switch self {
        case .available: return 0
        case .success: return 1
        case .loading: return 2
        case .loadingFailed: return 3
        case .response: return 4
        case .noResponse: return 5
        case .noData: return 6
        case .noImageAvailable: return 7
            
        case .uploading: return 10
        }
    }

    static func description(for value: Int) -> String {
        switch value {
        case ImageFetchResult.available.rawValue: return ImageFetchResult.available.description
        case ImageFetchResult.success(Data()).rawValue: return ImageFetchResult.success(Data()).description
        case ImageFetchResult.loading.rawValue: return ImageFetchResult.loading.description
        case 3:
            let error = Error.self
            return ImageFetchResult.loadingFailed(error as! Error).description
        case ImageFetchResult.response(HTTPURLResponse()).rawValue: return ImageFetchResult.response(HTTPURLResponse()).description
        case ImageFetchResult.noResponse.rawValue: return ImageFetchResult.noResponse.description
        case ImageFetchResult.noData.rawValue: return ImageFetchResult.noData.description
        case ImageFetchResult.noImageAvailable.rawValue: return ImageFetchResult.noImageAvailable.description
            
        case ImageFetchResult.uploading.rawValue: return ImageFetchResult.uploading.description
            
        default: return "No valid ImageFetchResult value"
        }
    }
}
