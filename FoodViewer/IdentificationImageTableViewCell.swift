//
//  IdentificationImageTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 16/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

protocol IdentificationImageCellDelegate: class {
    
    func identificationImageTableViewCell(_ sender: IdentificationImageTableViewCell, receivedActionOnCamera button:UIButton)
    func identificationImageTableViewCell(_ sender: IdentificationImageTableViewCell, receivedActionOnCameraRoll button:UIButton)
}

class IdentificationImageTableViewCell: UITableViewCell {


    fileprivate struct Constants {
        static let CellContentViewMargin = CGFloat(8)
    }

    @IBOutlet weak var takePhotoButton: UIButton! {
        didSet {
            takePhotoButton.isHidden = !editMode
        }
    }
    
    @IBAction func takePhotoButtonTapped(_ sender: UIButton) {
        delegate?.identificationImageTableViewCell(self, receivedActionOnCamera: sender)
    }
    
    @IBOutlet weak var useCameraRollButton: UIButton! {
        didSet {
            useCameraRollButton.isHidden = !editMode
        }
    }
    
    @IBAction func useCameraRollTapped(_ sender: UIButton) {
        delegate?.identificationImageTableViewCell(self, receivedActionOnCameraRoll: sender)
    }

    var editMode: Bool = false {
        didSet {
            takePhotoButton?.isHidden = !editMode
            useCameraRollButton?.isHidden = !editMode
        }
    }
    
    var delegate: IdentificationImageCellDelegate? = nil

    var identificationImage: UIImage? = nil {
        didSet {
            
            if let newImage = identificationImage {
                // print("product image size \(newImage.size)")
                // print("product contentView size \(self.contentView.frame.size)")
                // what to do if the image is wider than the contentView area of the cell's contentView?
                let widthScale = (newImage.size.width) / (self.contentView.frame.size.width - Constants.CellContentViewMargin * 2)
                // the height may not be larger than the width of the frame
                let heightScale =  (newImage.size.height) / (self.contentView.frame.size.width - Constants.CellContentViewMargin * 2)
                if (widthScale > 1) || (heightScale > 1) {
                    if widthScale > heightScale {
                        // width is the determining factor
                        let newSize = CGSize(width: newImage.size.width / widthScale, height: newImage.size.height / widthScale)
                        let scaledImage = newImage.imageResize(newSize)
                        identificationImageView?.image = scaledImage
                    } else {
                        // height is the determining factor
                        let newSize = CGSize(width: newImage.size.width / heightScale, height: newImage.size.height / heightScale)
                        let scaledImage = newImage.imageResize(newSize)
                        identificationImageView?.image = scaledImage
                    }
                } else {
                    identificationImageView?.image = newImage
                }
                // still need to solved what happens when the image is very high
                
                identificationImageView.contentMode = .center
                
                // print("product imageView size \(productImageView?.bounds.size)")
                // print("cell: \(self.contentView.bounds.size)")
                /*productImageView.image = newImage.squareCropImageToSideLength(productImageView) */
            } else {
                identificationImageView?.image = UIImage(named: "ImageLoading")
            }

        }
    }
    
    @IBOutlet weak var identificationImageView: UIImageView!
}
