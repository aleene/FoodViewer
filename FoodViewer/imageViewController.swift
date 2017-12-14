//
//  ImageViewController.swift
//  FoodViewer
//
//  Created by arnaud on 11/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    var imageData: ProductImageData?
    
    var imageTitle: String? = nil {
        didSet {
            title = imageTitle != nil ? imageTitle! : TranslatableStrings.NoTitle
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
        
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!

    private func setImage() {
        imageView?.image = currentImage()
        if let size = imageView?.image?.size {
            scrollView.updateMinZoomScale(for:size)
        }
        // adjust the constraints for the new image
        updateConstraints(for:view.bounds.size)
    }
    
    private func currentImage() -> UIImage? {
        if imageData != nil {
            if let result = imageData!.fetch() {
                switch result {
                case .available:
                    return imageData!.image
                // in the other case I should show a loading or impossible image
                case .loading:
                    return UIImage.init(named:"Loading")
                default:
                    break
                }
            }
        }
        return UIImage.init(named:"NotOK")
    }
    
    @objc func reloadImage() {
        setImage()
    }
    
    fileprivate func updateConstraints(for size: CGSize) {
        
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
        
        view.layoutIfNeeded()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        setImage()
        
        NotificationCenter.default.addObserver(self, selector:#selector(ImageViewController.reloadImage), name:.ImageSet, object:nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }
    
}

extension ImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraints(for:view.bounds.size)
    }
    
}

extension UIScrollView {
    
    struct Constants {
        static let MinimumZoomScale = CGFloat(5) // %
        static let MaximumZoomScale = CGFloat(500) // %
    }

    func updateMinZoomScale(for size: CGSize) {
        let widthScale = size.width / frame.size.width
        let heightScale = size.height / frame.size.height
    
        //  image larger than width scrollView ?
        if widthScale > 1.0 || heightScale > 1.0 {
            zoomScale = 1 / max(widthScale, heightScale) // ( widthScale > heightScale ? widthScale : heightScale )
        } else {
            // no zoom needed if image is smaller than screen
            zoomScale = 1.0
        }
        minimumZoomScale = zoomScale * Constants.MinimumZoomScale / 100
        maximumZoomScale = zoomScale * Constants.MaximumZoomScale / 100
    }
    
}
