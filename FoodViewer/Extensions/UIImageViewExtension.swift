//
//  UIImageViewExtension.swift
//  FoodViewer
//
//  Created by arnaud on 24/12/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

extension UIImageView {
    
    var imageRect: CGRect? {
        let imgViewSize = self.frame.size  // Size of UIImageView
        guard self.image != nil else { return nil }
        let imgSize = self.image!.size // Size of the image, currently displayed
    
        // guard self.contentMode == .scaleAspectFit else { return nil }
        // Calculate the aspect, assuming imgView.contentMode==UIViewContentModeScaleAspectFit
    
        let scaleW = imgViewSize.width / imgSize.width
        let scaleH = imgViewSize.height / imgSize.height
        let aspect = min(scaleW, scaleH)
    
        var imageRect = CGRect.init(x: 0.0, y: 0.0, width: imgSize.width * aspect, height: imgSize.height * aspect)
        
        // Center image
    
        imageRect.origin.x = (imgViewSize.width - imageRect.size.width) / 2
        imageRect.origin.y = (imgViewSize.height - imageRect.size.height) / 2
    
        // Add imageView offset
    
        imageRect.origin.x += self.frame.origin.x
        imageRect.origin.y += self.frame.origin.y
    
        return imageRect
    }

}
