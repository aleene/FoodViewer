//
//  ImageTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 27/11/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit


class ImageTableViewCell: UITableViewCell {

    @IBOutlet weak var cellImageView: UIImageView!


/**
Setup the cell with an ecoscore
- parameters :
     - image : image to be schown
*/
    func setup(ecoscore: Ecoscore?) {
        if let validEcoscore = ecoscore {
            self.cellImage = validEcoscore.image
        } else {
            self.cellImage = Ecoscore.unknown.image
        }
    }
    
    private var cellImage: UIImage? {
        didSet {
            cellImageView?.image = cellImage
        }
    }

}
