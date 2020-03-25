//
//  AddImageCollectionViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 16/08/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

protocol AddImageCollectionViewCellDelegate: class {
    
    // function to let the delegate know that a tag was single tapped
    func addImageCollectionViewCellAddFromCamera(_ sender: AddImageCollectionViewCell, receivedTapOn button:UIButton)
    
    // function to let the delegate know that a tag was single tapped
    func addImageCollectionViewCellAddFromCameraRoll(_ sender: AddImageCollectionViewCell, receivedTapOn button:UIButton)

}

class AddImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var addImageFromCameraButton: UIButton!
    
    @IBOutlet weak var addImageFromCameraRoll: UIButton!
    
    @IBAction func addImageFromCameraButtonTapped(_ sender: UIButton) {
        delegate?.addImageCollectionViewCellAddFromCamera(self, receivedTapOn: sender)
    }
    
    @IBAction func addImageFromCameraRollButtonTapped(_ sender: UIButton) {
        delegate?.addImageCollectionViewCellAddFromCameraRoll(self, receivedTapOn: sender)
    }
        
    var delegate: AddImageCollectionViewCellDelegate?
}
