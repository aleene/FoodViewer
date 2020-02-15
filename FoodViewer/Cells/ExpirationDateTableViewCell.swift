//
//  ExpirationDateTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 21/11/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

protocol ExpirationDateTableViewDelegate {
/**
Function to let the delegate know that the button was tapped.
                 
- parameters:
    - sender : the `TagListViewButtonTableViewCell` that is at the origin of the function call
    - button : the tagListView that has been tapped on
*/
    func expirationDateTableViewCell(_ sender: ExpirationDateTableViewCell, receivedTapOn button:UIButton)
}

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
    
    var delegate: ExpirationDateTableViewDelegate? = nil {
        didSet {
            expirationDateTextField?.delegate = delegate as? UITextFieldDelegate
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
        expirationDateTextField?.delegate = delegate as? UITextFieldDelegate
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
    
    @IBAction func expirationDateButtonTapped(_ sender: UIButton) {
        delegate?.expirationDateTableViewCell(self, receivedTapOn:sender)
    }
    

    @IBOutlet weak var expirationDateTextField: UITextField! {
        didSet {
            setTextFieldStyle()
        }
    }
    
}
