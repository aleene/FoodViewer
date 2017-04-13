//
//  StateTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 12/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class StateTableViewCell: UITableViewCell {

    var state: Bool = false {
        didSet {
            setImage()
        }
    }
    
    var stateTitle: String? = nil {
        didSet {
            var stateLabelText = stateTitle != nil ? stateTitle! : NSLocalizedString("none", comment: "Text for a cell, when no status title has been provided, such as 'completed', etc.")
            // add a question mark
            stateLabelText += "?"
            stateLabel.text = stateLabelText
        }
    }
    
    @IBOutlet weak var stateLabel: UILabel!
    
    @IBOutlet weak var stateImage: UIImageView! {
        didSet {
            setImage()
        }
    }
    
    private func setImage() {
        stateImage?.image = state ? UIImage.init(named: "OK") : UIImage.init(named: "NotOK")
    }
    
}
