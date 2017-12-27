//
//  ProductImageTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 17/10/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

protocol ProductImageCellDelegate: class {
    
    func productImageTableViewCell(_ sender: ProductImageTableViewCell, receivedActionOnCamera button:UIButton)
    func productImageTableViewCell(_ sender: ProductImageTableViewCell, receivedActionOnCameraRoll button:UIButton)
    func productImageTableViewCell(_ sender: ProductImageTableViewCell, receivedActionOnDeselect button: UIButton)
}

class ProductImageTableViewCell: UITableViewCell {

    
    fileprivate struct Constants {
        static let CellContentViewMargin = CGFloat(8)
    }
    
    var productImage: UIImage? = nil {
        didSet {
            if let newImage = productImage {
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
                        productImageView?.image = scaledImage
                    } else {
                        // height is the determining factor
                        let newSize = CGSize(width: newImage.size.width / heightScale, height: newImage.size.height / heightScale)
                        let scaledImage = newImage.imageResize(newSize)
                        productImageView?.image = scaledImage
                    }
                } else {
                    productImageView?.image = newImage
                }
                // still need to solved what happens when the image is very high
                
                imageView?.contentMode = .center
                hideClearButton()
            } else {
                imageView?.image = UIImage(named: "ImageLoading")
            }
        }
    }
    
    var editMode: Bool = false {
        didSet {
            takePhotoButton?.isHidden = !editMode
            selectFromCameraRollButton?.isHidden = !editMode
            hideClearButton()
            // deselect button only relevant if there is a photo
        }
    }
    
    var delegate: ProductImageCellDelegate? = nil
    
    @IBOutlet weak var productImageView: UIImageView!
    
    @IBOutlet weak var takePhotoButton: UIButton! {
        didSet {
            takePhotoButton.isHidden = !editMode
        }
    }
    
    @IBAction func takePhotoButtonTapped(_ sender: UIButton) {
        delegate?.productImageTableViewCell(self, receivedActionOnCamera: sender)
    }
    
    @IBOutlet weak var selectFromCameraRollButton: UIButton! {
        didSet {
            selectFromCameraRollButton.isHidden = !editMode
        }
    }
    
    @IBAction func selectFromCamerRollButtonTapped(_ sender: UIButton) {
        delegate?.productImageTableViewCell(self, receivedActionOnCameraRoll: sender)
    }

    @IBOutlet weak var deselectImageButton: UIButton! {
        didSet {
            hideClearButton()
        }
    }
    
    private func hideClearButton() {
        deselectImageButton?.isHidden = productImage != nil ? !editMode : true
    }
    
    @IBAction func deselectImageButtonTapped(_ sender: UIButton) {
        delegate?.productImageTableViewCell(self, receivedActionOnDeselect: sender)
    }

}

