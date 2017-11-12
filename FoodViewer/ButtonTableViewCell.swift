//
//  ButtonTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 23/10/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

protocol ButtonCellDelegate: class {
    
    // function to let the delegate know that a tag was single tapped
    func buttonTableViewCell(_ sender: ButtonTableViewCell, receivedTapOn button:UIButton)
}

class ButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var button: UIButton! {
        didSet {
            button.isEnabled = editMode
            setTitle()
        }
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        delegate?.buttonTableViewCell(self, receivedTapOn: sender)
    }
    
    public var delegate: ButtonCellDelegate? = nil
    
    public var title: String? = nil {
        didSet {
            setTitle()
        }
    }
    
    public var editMode: Bool = false {
        didSet {
            button.isEnabled = editMode
        }
    }
    
    private func setTitle() {
        if let validTitle = title {
            button.setTitle(validTitle, for: .normal)
        }
    }
}
