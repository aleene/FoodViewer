//
//  GKImageCropView.swift
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

class GKImageCropView: UIView {
    
    private func rad(_ angle: CGFloat) -> CGFloat {
        return angle / CGFloat(180.0) * CGFloat(M_PI)
    }
    
    private func GKScaleRect(rect: CGRect, scale: CGFloat) -> CGRect {
        return CGRect.init(x: rect.origin.x * scale,
                           y: rect.origin.y * scale,
                           width: rect.size.width * scale,
                           height: rect.size.height * scale)
    }
    
    lazy var scrollView: ScrollView = {
        let view = ScrollView.init()
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        // view.clipsToBounds = true
        view.decelerationRate = 0.0
        view.backgroundColor = UIColor.clear
        view.maximumZoomScale = 20.0
        view.minimumZoomScale = 0.1
        view.zoomScale = 1.0
        view.delegate = self
        return view
    } ()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView.init()
        // view.contentMode = .scaleAspectFit
        // view.backgroundColor = .black
        
        return view

    } ()
    
    var cropOverlayView: GKImageCropOverlayView? = nil
    
    var xOffset: CGFloat = 0.0
    var yOffset: CGFloat = 0.0
    
    var hasResizableCropArea = false
    
    var imageToCrop: UIImage? = nil {
        didSet {
            self.imageView.image = self.imageToCrop
        }
    }

    var cropSize: CGSize = CGSize.zero {
        didSet {
            self.cropOverlayView = hasResizableCropArea ? GKResizeableCropOverlayView.init(frame: self.bounds) : GKImageCropOverlayView.init(frame: self.bounds)
            self.cropOverlayView?.initialCropSize = self.cropSize
            addSubview(self.cropOverlayView!)
            self.layoutSubViews()
        }
    }
    
    // MARK: - Public Methods
    
    func croppedImage() -> UIImage? {
        //Calculate rect that needs to be cropped
        var visibleRect = calcCropArea()
        //transform visible rect to image orientation
        let rectTransform: CGAffineTransform = _orientationTransformedRectOfImage(img: self.imageToCrop!)
        
        visibleRect = visibleRect.applying(rectTransform)
    
        //finally crop image
        if let imageRef = (self.imageToCrop!.cgImage)!.cropping(to: visibleRect) {
            return UIImage.init(cgImage: imageRef, scale: self.imageToCrop!.scale, orientation: self.imageToCrop!.imageOrientation)
        } else {
            return nil
        }
    }
    
    private func calcCropArea() -> CGRect {
        var sizeScale = self.imageView.image!.size.width / self.imageView.frame.size.width
        sizeScale *= self.scrollView.zoomScale
        
        //then get the position of the cropping rect inside the image
        let visibleRect = self.cropOverlayView?.contentView.convert(self.cropOverlayView!.contentView.bounds, to: imageView)
        let rect = GKScaleRect(rect: visibleRect!, scale: sizeScale)
        return rect
    }
    
    /*
    private func _calcVisibleRectForResizeableCropArea() -> CGRect {
        if let resizableView = cropOverlayView as? GKResizeableCropOverlayView {
    
            //first of all, get the size scale by taking a look at the real image dimensions. Here it doesn't matter if you take
            //the width or the hight of the image, because it will always be scaled in the exact same proportion of the real image
            var sizeScale = self.imageView.image!.size.width / self.imageView.frame.size.width
            sizeScale *= self.scrollView.zoomScale
    
            //then get the position of the cropping rect inside the image
            
            let visibleRect = resizableView.contentView.convert(resizableView.contentView.bounds, to: imageView)
            return GKScaleRect(rect: visibleRect, scale: sizeScale)
        }
        return CGRect.zero
    }
    
    private func _calcVisibleRectForCropArea() -> CGRect {
    //scaled width/height in regards of real width to crop width
        if let validImageToCrop = self.imageToCrop {
            let scaleWidth = validImageToCrop.size.width / self.cropSize.width
            let scaleHeight = validImageToCrop.size.height / self.cropSize.height
            var scale = CGFloat(0.0)
    
            if self.cropSize.width > self.cropSize.height {
                scale = validImageToCrop.size.width < validImageToCrop.size.height ?
                    max(scaleWidth, scaleHeight) :
                    min(scaleWidth, scaleHeight);
            } else {
                scale = validImageToCrop.size.width < validImageToCrop.size.height ?
                    min(scaleWidth, scaleHeight) :
                    max(scaleWidth, scaleHeight);
            }
            
            //extract visible rect from scrollview and scale it
            let visibleRect = scrollView.convert(scrollView.bounds, to: imageView)
            return GKScaleRect(rect: visibleRect, scale: scale)
        }
        return CGRect.zero
    }
     */
    
    
    private func _orientationTransformedRectOfImage(img: UIImage) -> CGAffineTransform {
    // {
        var rectTransform = CGAffineTransform()
        switch (img.imageOrientation) {
            case .left:
                rectTransform = CGAffineTransform(rotationAngle: rad(90)).translatedBy(x: 0, y: -img.size.height);
                break
            case .right:
                rectTransform = CGAffineTransform(rotationAngle: rad(-90)).translatedBy(x: -img.size.width, y: 0);
                break
            case .down:
                rectTransform = CGAffineTransform(rotationAngle: rad(-180)).translatedBy(x: -img.size.width, y: -img.size.height);
                break
            default:
                rectTransform = .identity;
        }
    
        return rectTransform.scaledBy(x: img.scale, y: img.scale);
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.isUserInteractionEnabled = true
        self.addSubview(scrollView)
        self.scrollView.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if hasResizableCropArea {
        
            if let resizeableCropView: GKResizeableCropOverlayView = cropOverlayView as? GKResizeableCropOverlayView {
        
                let outerFrame = resizeableCropView.cropBorderView.frame.insetBy(dx: -10, dy: -10)
                if outerFrame.contains(point) {
                    if (resizeableCropView.cropBorderView.frame.size.width < 60 || resizeableCropView.cropBorderView.frame.size.height < 60 ) {
                        return super.hitTest(point, with: event)
                    }
                    let innerTouchFrame = resizeableCropView.cropBorderView.frame.insetBy(dx: 30, dy: 30)
                    if innerTouchFrame.contains(point) {
                        return scrollView
                    }
                
                    let outBorderTouchFrame = resizeableCropView.cropBorderView.frame.insetBy(dx: -10, dy: -10)
                    if outBorderTouchFrame.contains(point) {
                        return super.hitTest(point, with: event)
                    }
            
                    return super.hitTest(point, with: event)
                }
            }
        }
        return scrollView;
    }
    
    private struct Constant {
        static let BorderCorrectionValue = CGFloat(12.0)
    }
    func layoutSubViews() {
        super.layoutSubviews()
        
        // This fits the image into the crop area
        let toolbarHeight = UIDevice.current.userInterfaceIdiom == .pad ? CGFloat(44.0) : CGFloat(54.0)
        
        
        var faktor = CGFloat(0.0)
        var faktoredHeight = CGFloat(0.0)
        var faktoredWidth = CGFloat(0.0)
        
        let correctedWidth = self.bounds.width - 2 * Constant.BorderCorrectionValue // width corrected for the handles
        let correctedHeight = self.bounds.height - 2 * Constant.BorderCorrectionValue - toolbarHeight// width corrected for the handles
        
        // print("cropSize", cropSize, imageToCrop!.size)
        if self.imageToCrop!.size.width > self.imageToCrop!.size.height {
            faktor = self.imageToCrop!.size.width / correctedWidth;
            faktoredWidth = correctedWidth
            faktoredHeight =  self.imageToCrop!.size.height / faktor
            self.yOffset = toolbarHeight  // ( faktoredHeight - self.scrollView.bounds.size.height ) / 2

        } else {
            faktor = self.imageToCrop!.size.height / correctedHeight
            faktoredWidth = self.imageToCrop!.size.width / faktor
            faktoredHeight =  correctedHeight
            self.yOffset = toolbarHeight // ( faktoredHeight - self.scrollView.bounds.size.height ) / 2
        }
 

        self.cropOverlayView?.frame = self.bounds // do NOT correct for the toolbar, it will be done in the class
        // the scrollView is the size of the visible view
        self.scrollView.frame = CGRect.init(x: 0, y: toolbarHeight, width: self.bounds.width, height: self.bounds.height - toolbarHeight) // CGRect.init(x: self.xOffset, y: self.yOffset, width: cropSize.width, height: cropSize.height)
        // the scrollView content size is the size of the image
        self.scrollView.contentSize = imageView.image!.size // CGSize.init(width: self.cropSize.width, height: self.cropSize.height)
        // The image should fit the scrollview (aspectFit)
        self.xOffset = 0 // ( faktoredWidth - self.scrollView.bounds.size.width ) / 2
        self.imageView.frame = CGRect.init(x: Constant.BorderCorrectionValue, y: Constant.BorderCorrectionValue, width: faktoredWidth, height: faktoredHeight)
        // move the content of the scrollView, so the image is centered in the window
        self.scrollView.contentOffset = CGPoint.init(x: self.xOffset, y: self.yOffset)
        // print("offset",xOffset,yOffset)
        // print("scroll",scrollView.frame, scrollView.bounds)
        // print("image",imageView.frame,imageView.bounds)
        // If this is not set the app will crash upon pinch
        self.scrollView.minimumZoomScale = 0.2 // scrollView.frame.width / imageView.frame.width
    }
    
    
}

extension GKImageCropView: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
}
