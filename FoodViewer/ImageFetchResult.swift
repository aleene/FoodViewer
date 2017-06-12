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
    case noData
    case noImageAvailable
    case uploading
    
    func description() -> String {
        switch self {
        case .available: return NSLocalizedString("Image is available", comment: "String presented in a tagView if the image is available")
        case .success: return NSLocalizedString("Data is loaded", comment: "String presented in a tagView if the data has been loaded")
        case .loading: return NSLocalizedString("Image is being loaded", comment: "String presented in a tagView if the image is currently being loaded")
        case .loadingFailed: return NSLocalizedString("Image loading has failed", comment: "String presented in a tagView if the image loading has failed")
        case .noData: return NSLocalizedString("Image was empty", comment: "String presented in a tagView if the image data contained no data")
        case .noImageAvailable: return NSLocalizedString("No image available", comment: "String presented in a tagView if no image is available")
        case .uploading: return NSLocalizedString("Uploading image", comment: "String presented in a tagView if an image is being uploaded")
        }
    }
    
    func retrieveImageData(_ url: URL?, cont: ((ImageFetchResult) -> Void)?) {
        if let imageURL = url {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
                do {
                    // This only works if you add a line to your Info.plist
                    // See http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http
                    //
                    let imageData = try Data(contentsOf: imageURL, options: NSData.ReadingOptions.mappedIfSafe)
                    if imageData.count > 0 {
                        // if we have the image data we can go back to the main thread
                        DispatchQueue.main.async(execute: { () -> Void in
                            // set the received image data to the current product if valid
                            cont?(.success(imageData))
                            return
                        })
                    } else {
                        DispatchQueue.main.async(execute: { () -> Void in
                            // set the received image data to the current product if valid
                            cont?(.noData)
                            return
                        })
                    }
                }
                catch {
                    DispatchQueue.main.async(execute: { () -> Void in
                        // set the received image data to the current product if valid
                        cont?(.loadingFailed(error))
                        return
                    })
                }
            })
        } else {
            cont?(.noImageAvailable)
            return
        }
    }

}
