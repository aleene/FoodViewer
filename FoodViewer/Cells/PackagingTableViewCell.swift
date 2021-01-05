//
//  PackagingTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 05/01/2021.
//  Copyright © 2021 Hovering Above. All rights reserved.
//

import UIKit

class PackagingTableViewCell: UITableViewCell {

    public var ecoscore: Ecoscore? {
        didSet {
            if let validEcoscore = ecoscore {
                ecoscoreView?.image = validEcoscore.image
            } else {
                ecoscoreView?.image = Ecoscore.unknown.image
            }
        }
    }
    
    @IBOutlet weak var ecoscoreView: UIImageView! {
        didSet {
            ecoscoreView?.image = Ecoscore.unknown.image
        }
    }
    
    
}
