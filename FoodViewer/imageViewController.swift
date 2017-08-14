//
//  imageViewController.swift
//  FoodViewer
//
//  Created by arnaud on 11/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class imageViewController: UIViewController, UIScrollViewDelegate {
    
    struct Constants {
        static let DefaultImageTitle = NSLocalizedString("No title", comment: "Title for viewcontroller with detailed product images, when no title is given. ")
        static let MinimumZoomScale = CGFloat(5) //%
        static let MaximumZoomScale = CGFloat(500) // %
    }
    
    var image: UIImage? {
        didSet {
            refresh()
        }
    }
    
    var imageTitle: String? = nil {
        didSet {
            title = imageTitle != nil ? imageTitle! : Constants.DefaultImageTitle
        }
    }
    
    // .Center in the Storyboard
    
    @IBOutlet weak var imageView: UIImageView!
        
    @IBOutlet weak var scrollView: UIScrollView!
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    fileprivate func refresh() {
        if let newImage = image {
            if imageView != nil {
                if scrollView != nil {
                    imageView?.image = newImage
                    // The scrollView contentSize should have the size of the image
                    scrollView!.contentSize = newImage.size
                    // The scrollView should be scaled such that the image fits just in the view
                    // either in height or in width
                    // print("scrollView: frame size \(scrollView!.frame.size); bounds size \(scrollView!.bounds.size)")
                    // print("image size: \(newImage.size)")
                    // width image larger than width scrollView
                    let widthScale = image!.size.width / scrollView!.frame.size.width
                    let heightScale = image!.size.height / scrollView!.frame.size.height
                    if (widthScale > 1.0) || (heightScale > 1.0) {
                        if widthScale > heightScale {
                            // fit the width
                            scrollView!.zoomScale = 1 / widthScale
                        } else {
                            // fit the height
                            scrollView!.zoomScale = 1 / heightScale
                        }
                    } else {
                        // no zoom needed
                        scrollView!.zoomScale = 1.0
                    }
                    scrollView!.minimumZoomScale = scrollView!.zoomScale * Constants.MinimumZoomScale / 100
                    scrollView!.maximumZoomScale = scrollView!.zoomScale * Constants.MaximumZoomScale / 100

                    // height image larger than height scrollView
                    // centerScrollViewContents()
                }
            }
        }
    }
    
    func reloadImage() {
        refresh()
    }
    
    // Adopted from: http://www.raywenderlich.com/76436/use-uiscrollview-scroll-zoom-content-swift
    //
    // The point of this function is to get around a slight annoyance with UIScrollView: if the scroll view content size is smaller than its bounds, then it sits at the top-left rather than in the center. Since you’ll be allowing the user to zoom out fully, it would be nice if the image sat in the center of the view. This function accomplishes that by positioning the image view such that it is always in the center of the scroll view’s bounds.

    fileprivate func centerScrollViewContents() {
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        imageView.frame = contentsFrame
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self

        refresh()
        
        NotificationCenter.default.addObserver(self, selector:#selector(imageViewController.reloadImage), name:.ImageSet, object:nil)

    }

}

private extension UIImage {
    
    // return the aspectRatio of the image
    var aspectRatio: CGFloat {
        return self.size.height != 0 ? self.size.width / self.size.height : 0
    }
}

private extension UIScrollView  {
    
    func minScale()-> CGFloat {
        return  min(self.frame.size.width / self.contentSize.width, self.frame.size.height / self.contentSize.height);
    }
}
