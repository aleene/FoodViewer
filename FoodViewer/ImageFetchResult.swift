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
    
    func retrieveImageData(url: NSURL?, cont: ((ImageFetchResult) -> Void)?) {
        if let imageURL = url {
            // self.nutritionImageData = .Loading
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                do {
                    // This only works if you add a line to your Info.plist
                    // See http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http
                    //
                    let imageData = try NSData(contentsOfURL: imageURL, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                    if imageData.length > 0 {
                        // if we have the image data we can go back to the main thread
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            // set the received image data to the current product if valid
                            cont?(.Success(imageData))
                            return
                        })
                    } else {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            // set the received image data to the current product if valid
                            cont?(.NoData)
                            return
                        })
                    }
                }
                catch {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        // set the received image data to the current product if valid
                        cont?(.LoadingFailed(error))
                        return
                    })
                }
            })
        } else {
            cont?(.NoImageAvailable)
            return
        }
    }

}