//
//  UIImageExtension.swift
//  FoodViewer
//
//  Created by arnaud on 22/12/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

extension UIImage {
    
    // https://stackoverflow.com/questions/158914/cropping-an-uiimage
    func crop(rect: CGRect) -> UIImage? {
        var scaledRect = rect
        scaledRect.origin.x *= scale
        scaledRect.origin.y *= scale
        scaledRect.size.width *= scale
        scaledRect.size.height *= scale
        guard let imageRef: CGImage = cgImage?.cropping(to: scaledRect) else {
            return nil
        }
        return UIImage(cgImage: imageRef, scale: scale, orientation: imageOrientation)
    }
    
    /*
     //  The orientation of a UIIamge is determined by the orientation of the camera when the picture was taken.
     //  This consists of two parts:
     //  - the origin of the image wrt the device: origin is always top-left,
     //      when the device is in landscape with the button on the right.
     //  - the imageOrientation (up/left/down/right)
     //
     //  External apps might not follow the imageOrientation, encoded in the EXIF.
     //  So better to fix the origin to the top-left of the image
     */

    func setOrientationToLeftUpCorner() -> UIImage {
        
        // up images should not be fixed
        guard self.imageOrientation != UIImageOrientation.up else { return self }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        // Rotate image clockwise by 90 degree
        
        var transform = CGAffineTransform.identity
        if (self.imageOrientation == UIImageOrientation.down
            || self.imageOrientation == UIImageOrientation.downMirrored) {
            
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi/2))
        }
        
        if (self.imageOrientation == UIImageOrientation.left
            || self.imageOrientation == UIImageOrientation.leftMirrored) {
            
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi/2))
        }
        
        if (self.imageOrientation == UIImageOrientation.right
            || self.imageOrientation == UIImageOrientation.rightMirrored) {
            
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi/2))
        }
        
        if (self.imageOrientation == UIImageOrientation.upMirrored
            || self.imageOrientation == UIImageOrientation.downMirrored) {
            
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        
        if (self.imageOrientation == UIImageOrientation.leftMirrored
            || self.imageOrientation == UIImageOrientation.rightMirrored) {
            
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx: CGContext = CGContext.init(data: nil,
                                            width: Int(self.size.width),
                                            height: Int(self.size.height),
                                            bitsPerComponent: self.cgImage!.bitsPerComponent,
                                            bytesPerRow: 0,
                                            space: self.cgImage!.colorSpace!,
                                            bitmapInfo: self.cgImage!.bitmapInfo.rawValue)!
        
        ctx.concatenate(transform)
        
        
        if (self.imageOrientation == UIImageOrientation.left
            || self.imageOrientation == UIImageOrientation.leftMirrored
            || self.imageOrientation == UIImageOrientation.right
            || self.imageOrientation == UIImageOrientation.rightMirrored
            || self.imageOrientation == UIImageOrientation.up
            ) {
            
            ctx.draw(self.cgImage!, in: CGRect.init(x: 0, y: 0, width: self.size.height, height: self.size.width))
        } else {
            ctx.draw(self.cgImage!, in: CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height))
        }
        
        
        // And now we just create a new UIImage from the drawing context
        let cgimg: CGImage = ctx.makeImage()!
        let imgEnd: UIImage = UIImage(cgImage: cgimg)
        
        return imgEnd
    }
    
    func imageResize (_ sizeChange:CGSize)-> UIImage {
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
    }
    
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

}

