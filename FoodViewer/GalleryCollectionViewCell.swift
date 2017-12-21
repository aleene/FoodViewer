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
    func galleryCollectionViewCell(_ sender: GalleryCollectionViewCell, receivedTapOn button:UIButton)
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
       delegate?.galleryCollectionViewCell(self, receivedTapOn: sender)
    }
    
    var delegate: GalleryCollectionViewCellDelegate? = nil
    
    var editMode: Bool = false {
        didSet {
            if let validIndexPath = indexPath {
                if validIndexPath.section > 2 {
                    button.setImage(UIImage.init(named: "Select"), for: .normal)
                } else {
                    button.setImage(UIImage.init(named: "ClearBlue"), for: .normal)
                }
                button.isHidden = !editMode
            }
        }
    }
    
    var indexPath: IndexPath? = nil {
        didSet {
            guard indexPath != nil else { return }
        }
    }
    
    var imageKey: String? = nil
}
