//
//  NutrientsImageTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 18/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class NutrientsImageTableViewCell: UITableViewCell {

    var nutritionFactsImage: UIImage? = nil {
        didSet {
            if let newImage = nutritionFactsImage {
                nutrientsImageView?.image = newImage
                // print("nutrients image size \(newImage.size)")
                nutrientsImageView?.sizeToFit()
                // print("nutrients imageView size \(nutrientsImageView?.bounds.size)")

            }
        }
    }

    @IBOutlet weak var nutrientsImageView: UIImageView! {
        didSet {
            nutrientsImageView.contentMode = .Center
        }
    }
}
