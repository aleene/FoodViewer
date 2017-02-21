//
//  GKImageCropOverlayView.swift
//  GKImagePickerSwift
//
//
//  Created by Georg Kitz on 6/1/12.
//  Copyright (c) 2012 Aurora Apps. All rights reserved.
//
//  Translated in Swift 3.0 by arnaud on 12/02/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation
import UIKit

// This class handles touch input on the overlay for the crop area
// It creates a clear pane through which the image is seen

class GKImageCropOverlayView: UIView {
    
    // MARK: - Getter/Setter
    
    var cropSize: CGSize = CGSize.zero
    
    // MARK: - Getter/Setter
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = true
        self.addSubview(self.contentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var toolbarSize: CGFloat {
        get {
            return UIDevice.current.userInterfaceIdiom == .pad ? CGFloat(44.0) : CGFloat(54.0)
        }
    }

    var contentViewFrame: CGRect {
        get {
            return CGRect.init(
                x: self.bounds.size.width / 2 - self.initialCropSize.width  / 2,
                y: (self.bounds.size.height - self.toolbarSize) / 2 - self.initialCropSize.height / 2,
                width: self.initialCropSize.width,
                height: self.initialCropSize.height)
        }
    }

    var contentView: UIView = {
        return UIView.init(frame: CGRect.zero)
    } ()
    

    var initialCropSize: CGSize = CGSize.zero {
        didSet {
            contentView.frame = contentViewFrame
            cropSize = initialCropSize
        }
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    
    override func draw(_ rect: CGRect) {
        let toolbarSize: CGFloat = UI_USER_INTERFACE_IDIOM() == .pad ? 0.0 : 54.0
        
        let width = frame.width
        let height = frame.height - toolbarSize
        
        let heightSpan = CGFloat(floor(height / 2 - cropSize.height / 2))
        let widthSpan = CGFloat(floor(width / 2 - cropSize.width / 2))
        
        //fill outer rect
        UIColor.init(colorLiteralRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.5).set()
        UIRectFill(self.bounds)
        
        //fill inner border
        UIColor.init(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.5).set()
        UIRectFrame(CGRect.init(x: widthSpan - 2, y: heightSpan - 2, width: cropSize.width + 4, height: cropSize.height + 4))
        
        //fill inner rect
        UIColor.clear.set()
        UIRectFill(CGRect.init(x: widthSpan, y: heightSpan, width: cropSize.width, height: cropSize.height))
        
        
// if heightSpan > 30 && (UIDevice.current.userInterfaceIdiom == .pad) {
            // UIColor.white.set()
            
            // let stringToDraw = NSLocalizedString("Move and scale", comment: "GKIMoveAndScale") as NSString
            // stringToDraw.draw(in: CGRect.init(x: 10.0, y: (height - heightSpan) + (heightSpan / 2 - CGFloat(20.0) / 2), width: width - CGFloat(20.0), height: 20.0),
            //                  withAttributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 20.0)] )
                                // , NSLineBreakMode: .byTruncatingTail])
            
            //[NSLocalizedString(@"GKImoveAndScale", @"") drawInRect:CGRectMake(10, (height - heightSpan) + (heightSpan / 2 - 20 / 2) , width - 20, 20)
            //    withFont:[UIFont boldSystemFontOfSize:20]
            //    lineBreakMode:NSLineBreakByTruncatingTail
            //    alignment:NSTextAlignmentCenter];
// }
    }

}

