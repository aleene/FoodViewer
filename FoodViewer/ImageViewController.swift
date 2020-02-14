//
//  ImageViewController.swift
//  FoodViewer
//
//  Created by arnaud on 11/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

protocol ImageViewControllerCoordinator {
    func imageViewController(_ sender:ImageViewController, tapped barButton:UIBarButtonItem)
}

class ImageViewController: UIViewController {
    
    var imageData: ProductImageData?
    
    var imageTitle: String? = nil {
        didSet {
            setTitle()
        }
    }
    
    var coordinator: (Coordinator & ImageViewControllerCoordinator)? = nil
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            if #available(iOS 11.0, *) {
                imageView.addInteraction(UIDragInteraction(delegate: self))
                imageView.isUserInteractionEnabled = true
            }
        }
    }
    @IBOutlet weak var navItem: UINavigationItem! {
        didSet {
            setTitle()
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        coordinator?.imageViewController(self, tapped:sender)
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!

    private func setTitle() {
        navItem?.title  = imageTitle != nil ? imageTitle! : TranslatableStrings.NoTitle
    }
    
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
                case .success(let image):
                    return image
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
        coordinator?.viewControllerDidDisappear(self)
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

extension ImageViewController: UIDragInteractionDelegate {
    
    @available(iOS 11.0, *)
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        
        guard let image = currentImage() else { return [] }
        let provider = NSItemProvider(object: image)
        let item = UIDragItem(itemProvider: provider)
        item.localObject = image
        
        return [item]
    }
    
}
