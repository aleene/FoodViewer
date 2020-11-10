//
//  GalleryCollectionViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 11/08/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

protocol GalleryCollectionViewCellDelegate: class {
    
    // function to let the delegate know that the deselect button has been tapped
    func galleryCollectionViewCell(_ sender: GalleryCollectionViewCell, receivedTapOn button:UIButton, for key:String?)
}

class GalleryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var button: UIButton! {
        didSet {
            button.isHidden = !editMode
        }
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        delegate?.galleryCollectionViewCell(self, receivedTapOn: sender, for:imageKey)
    }
    
    @IBOutlet weak var imageAgeButton: UIButton!
    
    @IBOutlet weak var progressView: UIView! {
        didSet {
            progressView.isHidden = true
        }
    }
    
    public var delegate: GalleryCollectionViewCellDelegate? = nil
    
// MARK: - public variables
    
    public var editMode: Bool = false {
        didSet {
            if let validIndexPath = indexPath {
                // Is this the section with all the images?
                if validIndexPath.section > 3 {
                    // Allows to assign an image
                    button.setImage(UIImage.init(named: "Select"), for: .normal)
                } else {
                    // Allows to deselect an image
                    button.setImage(UIImage.init(named: "Delete"), for: .normal)
                }
                button.isHidden = !editMode
            }
        }
    }
    
    public var indexPath: IndexPath? = nil {
        didSet {
            guard indexPath != nil else { return }
        }
    }
    
    /// The uploadTime of the image, calculated in seconds since 1970
    public var uploadTime: Double? {
        didSet {
            imageAgeButton?.isHidden = uploadTime == nil
            if uploadTime != nil {
                setImageAge()
            }
        }
    }

    public var imageKey: String? = nil
    
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
