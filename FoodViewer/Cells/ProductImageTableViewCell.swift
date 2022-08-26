//
//  ProductImageTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 17/10/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

protocol ProductImageCellDelegate: AnyObject {
    
    func productImageTableViewCell(_ sender: ProductImageTableViewCell, receivedActionOnCamera button:UIButton)
    func productImageTableViewCell(_ sender: ProductImageTableViewCell, receivedActionOnCameraRoll button:UIButton)
    func productImageTableViewCell(_ sender: ProductImageTableViewCell, receivedActionOnDeselect button: UIButton)
}

class ProductImageTableViewCell: UITableViewCell {

// MARK: - Constants
    
    fileprivate struct Constants {
        static let CellContentViewMargin = CGFloat(8)
    }
    
// MARK: - Public variables
    
    public var productImage: UIImage? = nil {
        didSet {
            if let newImage = productImage {
                // print("\(brandLabel): product image size \(newImage.size)")
                // what to do if the image is wider than the contentView area of the cell's contentView?
                let widthScale = (newImage.size.width) / (self.contentView.frame.size.width - Constants.CellContentViewMargin * 2)
                // the height may not be larger than the width of the frame
                let heightScale =  (newImage.size.height) / (self.contentView.frame.size.width - Constants.CellContentViewMargin * 2)
                if (widthScale > 1) || (heightScale > 1) {
                    if widthScale > heightScale {
                        // width is the determining factor
                        let newSize = CGSize(width: newImage.size.width / widthScale, height: newImage.size.height / widthScale)
                        let scaledImage = newImage.imageResize(newSize)
                        productImageView?.image = scaledImage
                    } else {
                        // height is the determining factor
                        let newSize = CGSize(width: newImage.size.width / heightScale, height: newImage.size.height / heightScale)
                        let scaledImage = newImage.imageResize(newSize)
                        productImageView?.image = scaledImage
                    }
                } else {
                    productImageView?.image = newImage
                }
                
                // still need to solved what happens when the image is very high
                
                imageView?.contentMode = .center
                hideClearButton()
            } else {
                imageView?.image = UIImage(named: "ImageLoading")
            }
            setButtonVisibility()
        }
    }
    
    public var editMode: Bool = false {
        didSet {
            setButtonVisibility()
            hideClearButton()
            layoutSubviews()
        }
    }
    
    public var delegate: ProductImageCellDelegate? = nil
    
    /// The uploadTime of the image, calculated in seconds since 1970
    public var uploadTime: Double? {
        didSet {
            imageAgeButton?.isHidden = uploadTime == nil
            if uploadTime != nil {
                setImageAge()
            }
        }
    }
    
    /// The upload progress ratio. If it is set to nil, the ratio indicator will be removed
    public var progressRatio: CGFloat? = nil {
        didSet {
            if let validRatio = progressRatio {
                progressView?.ratio = validRatio
                progressView?.isHidden = false
                // progressAtRatioView?.setNeedsDisplay()
            } else {
                progressView?.isHidden = true
            }
        }
    }
    
    
// MARK: - Storyboard elements
    
    @IBOutlet weak var productImageView: UIImageView! {
        didSet {
            setButtonVisibility()
        }
    }
    
    @IBOutlet weak var takePhotoButton: UIButton! {
        didSet {
            takePhotoButton.isHidden = !editMode
        }
    }
    
    @IBAction func takePhotoButtonTapped(_ sender: UIButton) {
        delegate?.productImageTableViewCell(self, receivedActionOnCamera: sender)
    }
    
    @IBOutlet weak var selectFromCameraRollButton: UIButton! {
        didSet {
            selectFromCameraRollButton.isHidden = !editMode
        }
    }
    
    @IBAction func selectFromCamerRollButtonTapped(_ sender: UIButton) {
        delegate?.productImageTableViewCell(self, receivedActionOnCameraRoll: sender)
    }

    @IBOutlet weak var deselectImageButton: UIButton! {
        didSet {
            hideClearButton()
        }
    }
    
    
    @IBAction func deselectImageButtonTapped(_ sender: UIButton) {
        delegate?.productImageTableViewCell(self, receivedActionOnDeselect: sender)
    }
    
    
    @IBOutlet weak var imageAgeButton: UIButton! {
        didSet {
            imageAgeButton?.isHidden = productImage == nil
            
            if #available(iOS 13.0, *) {
                if let image = UIImage(systemName: "stop.fill") {
                    imageAgeButton?.setImage(image.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
                }
            } else {
                if let image = UIImage(named: "Clear") {
                    imageAgeButton?.setImage(image.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
                }
            }
            setImageAge()
        }
    }
    
    @IBOutlet weak var progressView: ProgressAtRatioView! {
        didSet {
            progressView?.setup(prop: Property(style: GreenLightStyle()))
        }
    }
    
    @IBOutlet weak var tagListView: TagListView! {
        didSet {
            tagListView.isHidden = true
        }
    }
    
    // MARK: - Storyboard setters
    
    private func hideClearButton() {
        deselectImageButton?.isHidden = productImage != nil ? !editMode : true
    }

    private func setButtonVisibility() {
        imageAgeButton?.isHidden = productImage == nil
        takePhotoButton?.isHidden = !editMode
        selectFromCameraRollButton?.isHidden = !editMode
    }
    
    private func setImageAge() {
        guard let timeInterval = uploadTime else { return }
        let uploadDate = Date(timeIntervalSince1970: timeInterval)
        guard let validDate = uploadDate.ageInYears else { return }
        if validDate >= 4.0 {
            imageAgeButton?.tintColor = .purple
        } else if validDate >= 3.0 {
            imageAgeButton?.tintColor = .red
        } else if validDate >= 2.0 {
            imageAgeButton?.tintColor = .orange
        } else if validDate >= 1.0 {
            imageAgeButton?.tintColor = .yellow
        } else {
            imageAgeButton?.tintColor = .green
        }
    }

}

