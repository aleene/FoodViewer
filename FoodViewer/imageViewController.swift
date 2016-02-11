//
//  imageViewController.swift
//  FoodViewer
//
//  Created by arnaud on 11/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class imageViewController: UIViewController, UIScrollViewDelegate {

    var image: UIImage? = nil {
        didSet {
            refresh()
        }
    }
    
    var imageTitle: String? = nil {
        didSet {
            refresh()
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    private func refresh() {
        if let newImage = image {
            imageView?.image = newImage
            imageView?.sizeToFit()
            
            title = imageTitle != nil ? imageTitle! : "?"
            
            scrollView?.contentSize = newImage.size
            scrollView?.minimumZoomScale = scrollView.minScale();
            scrollView?.maximumZoomScale = 1.0
            scrollView?.zoomScale = scrollView.minScale();
            
            if scrollView != nil {
                centerScrollViewContents()
            }
        }
    }
    
    // Adopted from: http://www.raywenderlich.com/76436/use-uiscrollview-scroll-zoom-content-swift
    //
    // The point of this function is to get around a slight annoyance with UIScrollView: if the scroll view content size is smaller than its bounds, then it sits at the top-left rather than in the center. Since you’ll be allowing the user to zoom out fully, it would be nice if the image sat in the center of the view. This function accomplishes that by positioning the image view such that it is always in the center of the scroll view’s bounds.

    private func centerScrollViewContents() {
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
    
    private func pinchImage() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refresh()
    }

}

extension UIScrollView  {
    
    func minScale()-> CGFloat {
        return  min(self.frame.size.width / self.contentSize.width, self.frame.size.height / self.contentSize.height);
    }
}
