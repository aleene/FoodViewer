//
//  GKImagePicker.swift
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

open class GKImagePicker: NSObject {
    
    var imagePickerController: UIImagePickerController? = nil {
        didSet {
            self.imagePickerController?.delegate = self
            self.imagePickerController?.sourceType = sourceType
        }
    }
    
    var tag: Int = 0
    
    var cropSize = CGSize.zero
    
    var delegate: GKImagePickerDelegate? = nil
    
    var sourceType: UIImagePickerController.SourceType = .photoLibrary {
        didSet {
            self.imagePickerController?.sourceType = sourceType
        }
    }
    var hasResizeableCropArea = false
    
    func dismiss(animated: Bool, completion: (() -> Void)?) {
        imagePickerController?.dismiss(animated: animated, completion: nil)
    }
}

// MARK: - UIImagePicker Delegate Methods


extension GKImagePicker: GKImageCropControllerDelegate {
    
    public func imageCropController(_ imageCropController: GKImageCropViewController, didFinishWith croppedImage: UIImage?) {
        delegate?.imagePicker(self, cropped:croppedImage!)
    }
}


// These delegates are called when the user has selected an image from the library.

extension GKImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        delegate?.imagePickerDidCancel(self)
        picker.dismiss(animated: false, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        func setImage(image: UIImage) {
            let cropController = GKImageCropViewController.init()
            cropController.sourceImage = image
            cropController.view.frame = self.imagePickerController!.view!.bounds
            cropController.preferredContentSize = picker.preferredContentSize
            cropController.hasResizableCropArea = self.hasResizeableCropArea
            cropController.cropSize = self.cropSize
            cropController.delegate = self
            cropController.sourceType = self.sourceType
            picker.pushViewController(cropController, animated: false)
        }
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            setImage(image: image)
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            setImage(image: image)
        } else {
            print("error in imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])")
        }
        
    }
    
}
