//
//  ImagesPageTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 21/08/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

class ImagesPageTableViewCell: UITableViewCell {

    fileprivate struct Constants {
        static let CellContentViewMargin = CGFloat(8)
    }
        
    var productImage : UIImage? = nil {
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
                    
                productImageView.contentMode = .center
                    
                // print("product imageView size \(productImageView?.bounds.size)")
                // print("cell: \(self.contentView.bounds.size)")
                /*productImageView.image = newImage.squareCropImageToSideLength(productImageView) */
            } else {
                productImageView?.image = UIImage(named: "NoImage")
            }
        }
    }
        
    @IBOutlet weak var productImageView: UIImageView!
    
}
    
extension UIImage {
        
    func squareCropImageToSideLength(_ sideLength: CGFloat) -> UIImage {
        // input size comes from image
        let inputSize: CGSize = self.size
            
        // round up side length to avoid fractional output size
        let sideLength: CGFloat = ceil(sideLength)
            
        // output size has sideLength for both dimensions
        let outputSize: CGSize = CGSize(width: sideLength, height: sideLength)
            
        // calculate scale so that smaller dimension fits sideLength
        let scale: CGFloat = max(sideLength / inputSize.width,
                                sideLength / inputSize.height)
            
        // scaling the image with this scale results in this output size
        let scaledInputSize: CGSize = CGSize(width: inputSize.width * scale,
                                            height: inputSize.height * scale)
            
        // determine point in center of "canvas"
        let center: CGPoint = CGPoint(x: outputSize.width/2.0,
                                        y: outputSize.height/2.0)
            
        // calculate drawing rect relative to output Size
        let outputRect: CGRect = CGRect(x: center.x - scaledInputSize.width/2.0,
                                        y: center.y - scaledInputSize.height/2.0,
                                        width: scaledInputSize.width,
                                        height: scaledInputSize.height)
            
        // begin a new bitmap context, scale 0 takes display scale
        UIGraphicsBeginImageContextWithOptions(outputSize, true, 0)
            
        // optional: set the interpolation quality.
        // For this you need to grab the underlying CGContext
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.interpolationQuality = CGInterpolationQuality.high
            
        // draw the source image into the calculated rect
        self.draw(in: outputRect)
            
        // create new image from bitmap context
        let outImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            
        // clean up
        UIGraphicsEndImageContext()
            
        // pass back new image
        return outImage
    }
        
    func imageResize (_ sizeChange:CGSize)-> UIImage {
            
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
            
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
    }
}
