//
//  GKImagePickerProtocol.swift
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

public protocol GKImagePickerDelegate {
    
    /**
     * @method imagePicker:pickedImage: gets called when a user has chosen an image
     * @param imagePicker, the image picker instance
     * @param image, the picked and cropped image
     */
    
    func imagePicker(_ imagePicker: GKImagePicker, cropped image: UIImage)
    
    
    /**
     * @method imagePickerDidCancel: gets called when the user taps the cancel button
     * @param imagePicker, the image picker instance
     */
    
    func imagePickerDidCancel(_ imagePicker: GKImagePicker)
}


// MARK: - GKImagePickerDelegate

// This is the default implementation for these optional delegate methods

extension GKImagePickerDelegate {

    func imagePicker(_ imagePicker: GKImagePicker, cropped image: UIImage) { }
    
    func imagePickerDidCancel(_ imagePicker: GKImagePicker) { }
    
}
