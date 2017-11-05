//
//  SelectImageSourceViewController.swift
//  FoodViewer
//
//  Created by arnaud on 08/02/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit
import MobileCoreServices

class SelectImageSourceViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    internal struct Notification {
        static let ImageHasBeenChangedKey = "SelectImageSourceViewController.Notification.ImageHasBeenChanged.Key"
        static let OriginalViewControllerKey = "SelectImageSourceViewController.Notification.OriginalViewController.Key"
        static let ImageTypeKey = "SelectImageSourceViewController.Notification.ImageType.Key"
        static let FrontValue = "SelectImageSourceViewController.Notification.Front.Value"
    }

    var delegate: Any? = nil

    @IBOutlet weak var takePhotoButton: UIButton!
    
    @IBAction func takePhotoButtonTapped(_ sender: UIButton) {
        // opens the camera and allows the user to take an image and crop
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.mediaTypes = [kUTTypeImage as String]
            picker.delegate = self
            picker.allowsEditing = true
            present(picker, animated: true, completion: nil)
        }
    }
    @IBOutlet weak var navItem: UINavigationItem!

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var userInfo = info
        if delegate as? IdentificationTableViewController != nil {
            userInfo[Notification.ImageTypeKey] = Notification.FrontValue
        }
        picker.dismiss(animated: true, completion: nil)
        // notify the delegate
        NotificationCenter.default.post(name: .ImageHasBeenChanged, object: nil, userInfo: userInfo)
    }
    
    @IBOutlet weak var useCameraRollButton: UIButton!
    
    @IBAction func useCameraRollButtonTapped(_ sender: UIButton) {
        // shows a popover with the camera roll in a grid
        
    }
    
    // MARK: - ViewController Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navItem.title = TranslatableStrings.Select
    }
    
}


// Definition:
extension Notification.Name {
    static let ImageHasBeenChanged = Notification.Name("SelectImageSourceViewController.Notification.ImageHasBeenChanged")
}
