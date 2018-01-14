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
        case .available: return NSLocalizedString("Image is available", comment: "String presented in a tagView if the image is available")
        case .success: return NSLocalizedString("Data is loaded", comment: "String presented in a tagView if the data has been loaded")
        case .loading: return NSLocalizedString("Image is being loaded", comment: "String presented in a tagView if the image is currently being loaded")
        case .loadingFailed: return NSLocalizedString("Image loading has failed", comment: "String presented in a tagView if the image loading has failed")
        case .noData: return NSLocalizedString("Image was empty", comment: "String presented in a tagView if the image data contained no data")
        case .response: return NSLocalizedString("Got a response", comment: "String presented in a tagView if the image data contained no data")
        case .noImageAvailable: return NSLocalizedString("No image available", comment: "String presented in a tagView if no image is available")
        case .noResponse: return NSLocalizedString("No image available", comment: "String presented in a tagView if no image is available")
        case .uploading: return NSLocalizedString("Uploading image", comment: "String presented in a tagView if an image is being uploaded")
        }
    }
    
    /*
    func getImageFromWeb(_ urlString: String, closure: @escaping (UIImage?) -> ()) {
        guard let url = URL(string: urlString) else {
            return closure(nil)
        }
        let task = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print("error: \(String(describing: error))")
                return closure(nil)
            }
            guard response != nil else {
                print("no response")
                return closure(nil)
            }
            guard data != nil else {
                print("no data")
                return closure(nil)
            }
            DispatchQueue.main.async {
                closure(UIImage(data: data!))
            }
        }
        task.resume()
    }
    */

}
