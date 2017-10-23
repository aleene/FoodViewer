//
//  ButtonTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 23/10/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

class ButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var button: UIButton! {
        didSet {
            button.isEnabled = editMode
            setTitle()
        }
    }

    public var title: String? = nil {
        didSet {
            setTitle()
        }
    }
    
    public var editMode: Bool = false {
        didSet {
            button.isEnabled = editMode
            setTitle()
        }
    }
    
    private func setTitle() {
        if let validTitle = title {
            button.setTitle(validTitle, for: .normal)
        } else {
            if editMode {
                button.setTitle(TranslatableStrings.EnterDate, for: .normal)
            } else {
                button.setTitle(TranslatableStrings.NotSet, for: .normal)
            }
        }
    }
}
