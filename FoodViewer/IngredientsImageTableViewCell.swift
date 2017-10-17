//
//  IngredientsImageTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 24/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

protocol IngredientsImageCellDelegate: class {
    
    func ingredientsImageTableViewCell(_ sender: IngredientsImageTableViewCell, receivedActionOnCamera button:UIButton)
    func ingredientsImageTableViewCell(_ sender: IngredientsImageTableViewCell, receivedActionOnCameraRoll button:UIButton)
}

class IngredientsImageTableViewCell: UITableViewCell {

    fileprivate struct Constants {
        static let CellContentViewMargin = CGFloat(8)
    }

    var ingredientsImage: UIImage? = nil {
        didSet {
            if let newImage = ingredientsImage {
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
                        ingredientsImageView?.image = scaledImage
                    } else {
                        // height is the determining factor
                        let newSize = CGSize(width: newImage.size.width / heightScale, height: newImage.size.height / heightScale)
                        let scaledImage = newImage.imageResize(newSize)
                        ingredientsImageView?.image = scaledImage
                    }
                } else {
                    ingredientsImageView?.image = newImage
                }
                // still need to solved what happens when the image is very high
                
                ingredientsImageView.contentMode = .center
            } else {
                ingredientsImageView?.image = UIImage(named: "ImageLoading")
            }
        }
    }

    var editMode: Bool = false {
        didSet {
            takePhotoButton?.isHidden = !editMode
            selectFromCameraRollButton?.isHidden = !editMode
        }
    }

    var delegate: IngredientsImageCellDelegate? = nil

    @IBOutlet weak var ingredientsImageView: UIImageView!
    
    @IBOutlet weak var takePhotoButton: UIButton! {
        didSet {
            takePhotoButton.isHidden = !editMode
        }
    }

    
    @IBAction func takePhotoButtonTapped(_ sender: UIButton) {
        delegate?.ingredientsImageTableViewCell(self, receivedActionOnCamera: sender)
    }
    
    @IBOutlet weak var selectFromCameraRollButton: UIButton! {
        didSet {
            selectFromCameraRollButton.isHidden = !editMode
        }
    }

    
    @IBAction func selectFromCamerRollButtonTapped(_ sender: UIButton) {
        delegate?.ingredientsImageTableViewCell(self, receivedActionOnCameraRoll: sender)
    }
}
