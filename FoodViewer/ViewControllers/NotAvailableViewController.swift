//
//  NotAvailableViewController.swift
//  FoodViewer
//
//  Created by arnaud on 10/11/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import UIKit

class NotAvailableViewController: UIViewController {
    
    fileprivate enum ProductVersion {
        case remote // data as entered by the user
        //case remoteTags // data interpreted by off
        case new // new data as entered by the user locally
        
        var isRemote: Bool {
            switch self {
            case .new:
                return false
            default:
                return true
            }
        }
    }

//
// MARK : Interface elements
//
    @IBOutlet weak var addFrontImageLabel: UILabel! {
        didSet {
            addFrontImageLabel.text = "Add image of product front."
        }
    }
    
    @IBOutlet weak var takeFrontImageButton: UIButton! {
        didSet {
            takeFrontImageButton.setTitle("Take Front Image", for: .normal)
        }
    }
    
    @IBAction func takeFrontImageButtonTapped(_ sender: UIButton) {
        takePhoto(for: .front(""))
    }
    
    @IBOutlet weak var selectFrontImageButton: UIButton! {
        didSet {
            selectFrontImageButton.setTitle("Select Front Image", for: .normal)
        }
    }
    @IBAction func selectFrontImageButtonTapped(_ sender: UIButton) {
        selectCameraRollPhoto(for:.front(""))
    }

    @IBOutlet weak var addIngredientImageLabel: UILabel! {
        didSet {
            addFrontImageLabel.text = "Add image of product front."
        }
    }
    @IBOutlet weak var takeIngredientsImageButton: UIButton! {
        didSet {
            takeIngredientsImageButton.setTitle("Take Ingredients Image", for: .normal)
        }
    }
    
    @IBAction func takeIngredientsImageButtonTapped(_ sender: UIButton) {
        takePhoto(for: .ingredients(""))
    }

    @IBOutlet weak var selectIngredientsImageButton: UIButton! {
        didSet {
            selectIngredientsImageButton.setTitle("Select Ingredients Image", for: .normal)
        }
    }
    @IBAction func selectIngredientsImageButtonTapped(_ sender: UIButton) {
        selectCameraRollPhoto(for:.ingredients(""))
    }

    // Nutrition Images
    
    @IBOutlet weak var addNutritionImageLabel: UILabel! {
        didSet {
            addFrontImageLabel.text = "Add image of nutritional values."
        }
    }
    @IBOutlet weak var takeNutritionImageButton: UIButton! {
        didSet {
            takeNutritionImageButton.setTitle("Take Nutrition Image", for: .normal)
        }
    }
    @IBAction func takeNutritionImageButtonTapped(_ sender: UIButton) {
        takePhoto(for:.nutrition(""))
    }

    @IBOutlet weak var selectNutritionImageButton: UIButton! {
        didSet {
            selectNutritionImageButton.setTitle("Select Nutrition Image", for: .normal)
        }
    }
    @IBAction func selectNutritionImageButtonTapped(_ sender: UIButton) {
        selectCameraRollPhoto(for:.nutrition(""))
    }

    // Other Images
    
    @IBOutlet weak var addOtherImageLabel: UILabel! {
        didSet {
            addFrontImageLabel.text = "Add other images of product."
        }
    }
    
    @IBOutlet weak var takeOtherImageButton: UIButton! {
        didSet {
            takeOtherImageButton.setTitle("Take Other Image", for: .normal)
        }
    }
    
    @IBAction func takeOtherImageButtonTapped(_ sender: UIButton) {
        takePhoto(for: .general("takeOtherImageButtonTapped"))
    }

    @IBOutlet weak var selectOtherImageButton: UIButton! {
        didSet {
            selectOtherImageButton.setTitle("Select Other Image", for: .normal)
        }
    }
    
    @IBAction func selectOtherImageButtonTapped(_ sender: UIButton) {
        selectCameraRollPhoto(for: .general("selectOtherImageButtonTapped"))
    }
    
    fileprivate lazy var imagePicker: GKImagePicker = {
        let picker = GKImagePicker.init()
        picker.imagePickerController = UIImagePickerController.init()
        // picker.mediaTypes = [kUTTypeImage as String]
        return picker
    }()

    func takePhoto(for category:ImageTypeCategory) {
        // opens the camera and allows the user to take an image and crop
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.cropSize = CGSize.init(width: 300, height: 300)
            imagePicker.hasResizeableCropArea = true
            imagePicker.delegate = self
            imagePicker.imagePickerController?.modalPresentationStyle = .fullScreen
            imagePicker.sourceType = .camera
            imagePicker.tag = category.rawValue
            
            present(imagePicker.imagePickerController!, animated: true, completion: nil)
            if let popoverPresentationController = imagePicker.imagePickerController!.popoverPresentationController {
                popoverPresentationController.sourceRect = self.view.frame
                popoverPresentationController.sourceView = self.view
            }
        }
    }
    
    func selectCameraRollPhoto(for category: ImageTypeCategory) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.cropSize = CGSize.init(width: 300, height: 300)
            imagePicker.hasResizeableCropArea = true
            imagePicker.imagePickerController!.modalPresentationStyle = .fullScreen
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.tag = category.rawValue
            
            imagePicker.delegate = self
            
            present(imagePicker.imagePickerController!, animated: true, completion: nil)
            if let popoverPresentationController = imagePicker.imagePickerController!.popoverPresentationController {
                popoverPresentationController.sourceRect = self.view.frame
                popoverPresentationController.sourceView = self.view
            }
        }
    }
//
// MARK: - public variables
//
    var delegate: ProductPageViewController? = nil
    
    var editMode: Bool {
        return delegate?.editMode ?? false
    }
//
// MARK: - private variables
//
    
    fileprivate var productPair: ProductPair? {
        return delegate?.productPair
    }

    // Determines which version of the product needs to be shown, the remote or local
    // Default is the edited product version
    fileprivate var productVersion: ProductVersion = .new
    
    // The languageCode as defined by the user (double tapping/selecting)
    // The user can set for which language he wants to see the name/genericName and front image
    fileprivate var currentLanguageCode: String? {
        get {
            return delegate?.currentLanguageCode
        }
        set {
            delegate?.currentLanguageCode = newValue
        }
    }

    // This variable defined the languageCode that must be used to display the product data
    // This is either the languageCode selected by the user or the best match for the current product
    private var displayLanguageCode: String? {
        return currentLanguageCode ?? productPair?.product?.matchedLanguageCode(codes: Locale.preferredLanguageCodes)
    }
    fileprivate var originalImages: [String:ProductImageSize] {
        get {
            var newImages: [String:ProductImageSize] = [:]
            switch productVersion {
            //case .local:
            //    if let validImages = productPair?.localProduct?.images {
            //        newImages = validImages
            //    }
            case .remote:
                if let validImages = productPair?.remoteProduct?.images {
                    newImages = validImages
                }
            case .new:
                if let validImages = productPair?.localProduct?.images {
                    newImages = validImages
                }
                if let validImages = productPair?.remoteProduct?.images {
                    let images = validImages
                    newImages = newImages.merging(images, uniquingKeysWith: { (first, last) in last } )
                }
            }
            //images.count > 0 {
            //newImages = images.merging(images, uniquingKeysWith: { (first, last) in last } )
            return newImages
        }
    }

//
// MARK: - viewController lifecycle functions
//

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

}
//
// MARK: - UIImagePickerControllerDelegate Functions
//
extension NotAvailableViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //newImageSelected(info: info)
        picker.dismiss(animated: true, completion: nil)
    }

}
//
// MARK: - UIPopoverPresentationControllerDelegate Functions
//
extension NotAvailableViewController: UIPopoverPresentationControllerDelegate {
    
    // MARK: - Popover delegation functions
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navcon = UINavigationController(rootViewController: controller.presentedViewController)
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        visualEffectView.frame = navcon.view.bounds
        navcon.view.insertSubview(visualEffectView, at: 0)
        return navcon
    }

}
//
// MARK: - GKImagePickerDelegate Functions
//
extension NotAvailableViewController: GKImagePickerDelegate {
    
    func imagePicker(_ imagePicker: GKImagePicker, cropped image: UIImage) {
        guard let validLanguageCode = displayLanguageCode else { return }
        switch imagePicker.tag {
        case 1:
            productPair?.update(frontImage: image, for: validLanguageCode)
        case 2:
            productPair?.update(ingredientsImage: image, for: validLanguageCode)
        case 3:
            productPair?.update(nutritionImage: image, for: validLanguageCode)
        default:
            let newImageID = "\(originalImages.count + 1)"
            productPair?.update(image: image, id: newImageID)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
//
// MARK: - GKImageCropController Delegate Methods
//
extension NotAvailableViewController: GKImageCropControllerDelegate {
    
    public func imageCropController(_ imageCropController: GKImageCropViewController, didFinishWith croppedImage: UIImage?) {
        guard let validLanguageCode = displayLanguageCode,
            let validImage = croppedImage else { return }
        imageCropController.dismiss(animated: true, completion: nil)
        switch imagePicker.tag {
        case 1:
            productPair?.update(frontImage: validImage, for: validLanguageCode)
        case 2:
            productPair?.update(ingredientsImage: validImage, for: validLanguageCode)
        case 3:
            productPair?.update(nutritionImage: validImage, for: validLanguageCode)
        default:
            let newImageID = "\(originalImages.count + 1)"
            productPair?.update(image: validImage, id: newImageID)
        }
    }
}
