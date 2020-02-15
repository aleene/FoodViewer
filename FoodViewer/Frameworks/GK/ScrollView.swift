//
//  ScrollView.swift
//  GKImagePickerSwift
//
//
//  Created by Georg Kitz on 6/1/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//
//  Translated in Swift 3.0 by arnaud on 12/02/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

class ScrollView: UIScrollView {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let zoomView = delegate?.viewForZooming!(in: self) {
            let boundsSize: CGSize = self.bounds.size
            var frameToCenter: CGRect = zoomView.frame
            
            // center horizontally
            if frameToCenter.size.width < boundsSize.width {
                frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
            } else {
                frameToCenter.origin.x = 0
            }
            
            // center vertically
            if frameToCenter.size.height < boundsSize.height {
                frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
            } else {
                frameToCenter.origin.y = 0
            }
            zoomView.frame = frameToCenter
        }
    }

}
