//
//  NutrientsImageTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 18/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class NutrientsImageTableViewCell: UITableViewCell {

    internal struct Notification {
        static let ChangeLanguageButtonTappedKey = "NutrientsImageTableViewCell.Notification.ChangeLanguageButtonTapped.Key"
    }

    fileprivate struct Constants {
        static let CellContentViewMargin = CGFloat(44)
        static let NoLanguage = NSLocalizedString("none", comment: "Text for language of product, when there is no language defined.")
    }
    
    
    @IBOutlet weak var changeLanguageButton: UIButton! {
        didSet {
            setLanguageButton()
        }
    }
    
    @IBAction func changeLanguageButtonTapped(_ sender: UIButton) {
        let userInfo = [Notification.ChangeLanguageButtonTappedKey:sender]
        NotificationCenter.default.post(name: .NutrientsImageLanguageTapped, object: nil, userInfo: userInfo)
    }

    @IBOutlet weak var takePhotoButton: UIButton! {
        didSet {
            takePhotoButton.isHidden = !editMode
        }
    }
    
    @IBAction func takePhotoButtonTapped(_ sender: UIButton) {
        NotificationCenter.default.post(name: .NutritionTakePhotoButtonTapped, object: nil)
    }
    
    @IBOutlet weak var useCameraRollButton: UIButton! {
        didSet {
            useCameraRollButton.isHidden = !editMode
        }
    }
    
    @IBAction func useCameraRollTapped(_ sender: UIButton) {
        NotificationCenter.default.post(name: .NutritionSelectFromCameraRollButtonTapped, object: nil)
    }
    
    private func setLanguageButton() {
        changeLanguageButton?.isEnabled = editMode ? true : ( numberOfLanguages > 1 ? true : false )
    }

    var languageCode: String? = nil {
        didSet {
            let verboseLanguage = languageCode != nil ? OFFplists.manager.translateLanguage(languageCode!, language:Locale.preferredLanguages[0]) : Constants.NoLanguage
            changeLanguageButton.setTitle(verboseLanguage, for: UIControlState())
        }
    }
    
    var numberOfLanguages: Int = 0 {
        didSet {
            setLanguageButton()
        }
    }

    var editMode: Bool = false {
        didSet {
            takePhotoButton?.isHidden = !editMode
            useCameraRollButton?.isHidden = !editMode
        }
    }

    var nutritionFactsImage: UIImage? = nil {
        didSet {
            if let newImage = nutritionFactsImage {
                // print("\(brandLabel): product image size \(newImage.size)")
                // what to do if the image is wider than the contentView area of the cell's contentView?
                let widthScale = (newImage.size.width) / (self.contentView.frame.size.width - Constants.CellContentViewMargin * 2)
                // the height may not be larger than the width of the frame
                let heightScale =  (newImage.size.height) / (self.contentView.frame.size.width - Constants.CellContentViewMargin * 2)
                if (widthScale > 1) || (heightScale > 1) {
                    if widthScale > heightScale {
                        // width is the determining factor
                        let newSize = CGSize(width: newImage.size.width / widthScale, height: newImage.size.height / widthScale)
                        let scaledImage = newImage.imageResize(newSize)
                        nutrientsImageView?.image = scaledImage
                    } else {
                        // height is the determining factor
                        let newSize = CGSize(width: newImage.size.width / heightScale, height: newImage.size.height / heightScale)
                        let scaledImage = newImage.imageResize(newSize)
                        nutrientsImageView?.image = scaledImage
                    }
                } else {
                    nutrientsImageView?.image = newImage
                }
                // still need to solved what happens when the image is very high
                
                nutrientsImageView.contentMode = .center
                
                // print("product imageView size \(productImageView?.bounds.size)")
                // print("cell: \(self.contentView.bounds.size)")
                /*productImageView.image = newImage.squareCropImageToSideLength(productImageView) */
            } else {
                nutrientsImageView?.image = nil
            }
        }
    }

    @IBOutlet weak var nutrientsImageView: UIImageView!
}

// Definition:
extension Notification.Name {
    static let NutritionTakePhotoButtonTapped = Notification.Name("NutrientsImageTableViewCell.Notification.NutritionTakePhotoButtonTapped")
    static let NutritionSelectFromCameraRollButtonTapped = Notification.Name("NutrientsImageTableViewCell.Notification.NutritionSelectFromCameraRollButtonTapped")
    static let NutrientsImageLanguageTapped = Notification.Name("NutrientsImageTableViewCell.Notification.LanguageTapped")
}

