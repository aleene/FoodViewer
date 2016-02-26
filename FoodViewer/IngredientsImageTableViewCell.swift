//
//  IngredientsImageTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 24/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class IngredientsImageTableViewCell: UITableViewCell {

    var ingredientsImage: UIImage? = nil {
        didSet {
            if let newImage = ingredientsImage {
                ingredientsImageView?.image = newImage
                // print("nutrients image size \(newImage.size)")
                ingredientsImageView?.sizeToFit()
                // print("nutrients imageView size \(nutrientsImageView?.bounds.size)")
                
            }
        }
    }

    @IBOutlet weak var ingredientsImageView: UIImageView! {
        didSet {
            ingredientsImageView.contentMode = .Center
        }
    }

}
