//
//  GKImageCropControllerDelegate.swift
//  GKImagePickerSwift
//
//
//  Created by Georg Kitz on 6/1/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//
//  Translated in Swift 3.0 by arnaud on 12/02/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

public protocol GKImageCropControllerDelegate {
    
    func imageCropController(_ imageCropController: GKImageCropViewController, didFinishWith croppedImage: UIImage?)

}

// This is the default implementation in case the protocol function is optional

extension GKImageCropControllerDelegate {
    
    func imageCropController(_ imageCropController: GKImageCropViewController, didFinishWith croppedImage: UIImage?) { }
}
