//
//  CommunityTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 12/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class CommunityTableViewCell: UITableViewCell {

    var product: FoodProduct? = nil {
        didSet {
            if let users = product?.productContributors.contributors {
                communityLabel?.text = "\(users.count) unique users involved"
            }
        }
    }

    @IBOutlet weak var communityLabel: UILabel!
    

}
