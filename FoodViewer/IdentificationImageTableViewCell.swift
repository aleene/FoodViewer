//
//  IdentificationImageTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 16/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class IdentificationImageTableViewCell: UITableViewCell {

    internal struct Notification {
        static let AddImageTappedKey = "IdentificationImageTableViewCell.Notification.AddImageTapped.Key"
    }

    fileprivate struct Constants {
        static let CellContentViewMargin = CGFloat(8)
    }

    @IBOutlet weak var addImageButton: UIButton! {
        didSet {
            addImageButton.isHidden = !editMode
        }
    }
    
    @IBAction func addImageButtonTapped(_ sender: UIButton) {
        let userInfo = [Notification.AddImageTappedKey:sender]
        NotificationCenter.default.post(name: .AddImageTapped, object: nil, userInfo: userInfo)
    }
    
    var editMode: Bool = false {
        didSet {
            addImageButton?.isHidden = !editMode
        }
    }

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

// Definition:
extension Notification.Name {
    static let AddImageTapped = Notification.Name("IdentificationImageTableViewCell.Notification.AddImageTapped")
}

