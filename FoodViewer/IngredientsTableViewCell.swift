//
//  IngredientsTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 01/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class IngredientsTableViewCell: UITableViewCell {
    
    private struct Constants {
        static let ImageSize = CGFloat(81)
    }

    private var productImage : UIImage? = nil {
        didSet {
            // the ImageView size is set to 81x81
            // in the storyboard the view mode is set to Aspect Fit
            // but this should depend on the actual image size
            // if the image is large than 81 in either direction Aspect Fit is OK
            // Otherwise just center it.
            if let newImage = productImage {
                print("image size \(newImage)")
                
                ingredientsSmallImageView.image = newImage.squareCropImageToSideLength(Constants.ImageSize)
            }
            // print("image view \(ingredientsSmallImageView.bounds.size)")
        }
    }


    var product: FoodProduct? = nil {
        didSet {
            if let ingredients = product?.ingredients {
                // TBD what about allergen ingredients?
                ingredientsLabel.text = ingredients
            }
            if let imageURL = product?.imageIngredientsSmallUrl {
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
                    do {
                        // This only works if you add a line to your Info.plist
                        // See http://stackoverflow.com/questions/31254725/transport-security-has-blocked-a-cleartext-http
                        //
                        let imageData = try NSData(contentsOfURL: imageURL, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                        if imageData.length > 0 {
                            // if we have the image data we can go back to the main thread
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                if imageURL == self.product!.imageIngredientsSmallUrl! {
                                    // set the received image
                                    self.productImage = UIImage(data: imageData)
                                }
                            })
                        }
                    }
                    catch {
                        print(error)
                    }
                })

            }
        }
    }

    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var ingredientsSmallImageView: UIImageView!
    
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

}