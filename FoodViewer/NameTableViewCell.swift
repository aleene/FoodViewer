//
//  NameTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 06/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class NameTableViewCell: UITableViewCell {
    
    private struct Constants {
        static let NoBrandsIndicated = "No brands indicated"
        static let CellContentViewMargin = CGFloat(8)
    }
    
    var productImage : UIImage? = nil {
        didSet {
            
            if let newImage = productImage {
                // print("\(brandLabel): product image size \(newImage.size)")
                // what to do if the image is wider than the contentView area of the cell's contentView?
                let widthScale = (newImage.size.width) / (self.contentView.frame.size.width - Constants.CellContentViewMargin * 2)
                if widthScale > 0 {
                    let newSize = CGSize(width: newImage.size.width / widthScale, height: newImage.size.height / widthScale)
                    let scaledImage = newImage.imageResize(newSize)
                    productImageView?.image = scaledImage
                } else {
                    productImageView?.image = newImage
                }
                // still need to solved what happens when the image is very high
                
                productImageView.contentMode = .Center

                // print("product imageView size \(productImageView?.bounds.size)")
                // print("cell: \(self.contentView.bounds.size)")
                /*productImageView.image = newImage.squareCropImageToSideLength(productImageView) */
            }
        }
    }
    
    var productBrand: [String]? = nil {
        didSet {
            brandLabel.text = productBrand != nil ? productBrand![0] : Constants.NoBrandsIndicated
        }
    }

    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView! {
        didSet {

        }
    }

}

extension UIImage {
    
    func squareCropImageToSideLength(sideLength: CGFloat) -> UIImage {
        // input size comes from image
        let inputSize: CGSize = self.size
        
        // round up side length to avoid fractional output size
        let sideLength: CGFloat = ceil(sideLength)
        
        // output size has sideLength for both dimensions
        let outputSize: CGSize = CGSizeMake(sideLength, sideLength)
        
        // calculate scale so that smaller dimension fits sideLength
        let scale: CGFloat = max(sideLength / inputSize.width,
            sideLength / inputSize.height)
        
        // scaling the image with this scale results in this output size
        let scaledInputSize: CGSize = CGSizeMake(inputSize.width * scale,
            inputSize.height * scale)
        
        // determine point in center of "canvas"
        let center: CGPoint = CGPointMake(outputSize.width/2.0,
            outputSize.height/2.0)
        
        // calculate drawing rect relative to output Size
        let outputRect: CGRect = CGRectMake(center.x - scaledInputSize.width/2.0,
            center.y - scaledInputSize.height/2.0,
            scaledInputSize.width,
            scaledInputSize.height)
        
        // begin a new bitmap context, scale 0 takes display scale
        UIGraphicsBeginImageContextWithOptions(outputSize, true, 0)
        
        // optional: set the interpolation quality.
        // For this you need to grab the underlying CGContext
        let context: CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextSetInterpolationQuality(context, CGInterpolationQuality.High)
        
        // draw the source image into the calculated rect
        self.drawInRect(outputRect)
        
        // create new image from bitmap context
        let outImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // clean up
        UIGraphicsEndImageContext()
        
        // pass back new image
        return outImage
    }
    
    func imageResize (sizeChange:CGSize)-> UIImage {
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        self.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
}
