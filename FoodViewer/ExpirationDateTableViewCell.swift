//
//  ExpirationDateTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 21/11/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class ExpirationDateTableViewCell: UITableViewCell {

    fileprivate struct Constants {
        static let NoExpirationDate = NSLocalizedString("No expiration date", comment: "Title of cell when no expiration date is avalable")
    }

    var date: Date? = Date.init(timeIntervalSinceNow: 0.0) {
        didSet {
            setTextFieldStyle()
        }
    }

    var editMode: Bool = false {
        didSet {
            if editMode != oldValue {
                setTextFieldStyle()
            }
        }
    }

    private func setTextFieldStyle() {
        if let validDate = date {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            expirationDateTextField?.text = formatter.string(from: validDate as Date)
        } else {
            expirationDateTextField?.text = Constants.NoExpirationDate
        }
        expirationDateTextField?.layer.borderWidth = 0.0
        expirationDateTextField?.isEnabled = editMode
        expirationDateButton?.isHidden = !editMode
        expirationDateTextField?.backgroundColor = editMode ? UIColor.lightGray : UIColor.white
        expirationDateTextField?.borderStyle = editMode ? .roundedRect : .none
    }

    @IBOutlet weak var expirationDateButton: UIButton!
    
    @IBOutlet weak var expirationDateTextField: UITextField! {
        didSet {
            setTextFieldStyle()
        }
    }
    
}
