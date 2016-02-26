//
//  IdentificationImageTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 16/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class IdentificationImageTableViewCell: UITableViewCell {

    var identificationImage: UIImage? = nil {
        didSet {
            if let newImage = identificationImage {
                identificationImageView?.image = newImage
                // print("nutrients image size \(newImage.size)")
                identificationImageView?.sizeToFit()
                // print("nutrients imageView size \(nutrientsImageView?.bounds.size)")
                
            }
        }
    }
    
    @IBOutlet weak var identificationImageView: UIImageView! {
        didSet {
            identificationImageView.contentMode = .ScaleAspectFit
        }
    }

}
