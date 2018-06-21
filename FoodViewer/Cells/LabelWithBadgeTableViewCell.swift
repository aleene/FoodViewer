//
//  LabelWithBadgeTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 20/06/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import UIKit

class LabelWithBadgeTableViewCell: UITableViewCell {

    @IBOutlet weak var badgeView: UIView!
    
    @IBOutlet weak var badgeLabel: UILabel!
    
    @IBOutlet weak var label: UILabel!
    
    public var badgeText: String = "" {
        didSet {
            badgeLabel.text = badgeText
        }
    }
    
    public var labelText: String = "" {
        didSet {
        label.text = labelText
        }
    }
}
