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
        static let NoExpirationDate = TranslatableStrings.NoExpirationDate
    }

    var date: Date? = nil {
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
    
    var delegate: UITextFieldDelegate? = nil {
        didSet {
            expirationDateTextField?.delegate = delegate
        }
    }
    
    override var tag: Int {
        didSet {
            expirationDateTextField?.tag = tag
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
        // expirationDateTextField?.layer.borderWidth = 0.0
        expirationDateTextField?.delegate = delegate
        expirationDateTextField?.tag = tag
        expirationDateTextField?.isEnabled = false
        expirationDateButton?.isHidden = !editMode
        if #available(iOS 13.0, *) {
            expirationDateTextField?.backgroundColor = editMode ? .secondarySystemBackground : .systemBackground
        } else {
            expirationDateTextField?.backgroundColor = editMode ? .lightGray : .white
        }
        expirationDateTextField?.borderStyle = .none // editMode ? .roundedRect : .none
    }

    @IBOutlet weak var expirationDateButton: UIButton! {
        didSet {
            expirationDateButton.isHidden = !editMode
            }
    }
    
    @IBAction func expirationDateButtonTapped(_ sender: UIButton) {  }
    

    @IBOutlet weak var expirationDateTextField: UITextField! {
        didSet {
            setTextFieldStyle()
        }
    }
    
}
