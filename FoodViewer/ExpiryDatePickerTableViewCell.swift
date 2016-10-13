//
//  ExpiryDatePickerTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 28/09/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class ExpiryDatePickerTableViewCell: UITableViewCell {
    
    internal struct Notification {
        static let ExpiryDateHasBeenSetKey = "ExpiryDatePickerTableViewCell.Notification.ExpiryDateHasBeenSet.Key"
    }
    
    var currentDate: Date? {
        didSet {
            if let validDate = currentDate {
                expiryDatePickerView.date = validDate
            }
        }
    }

    private var expiryDate: Date? {
        didSet {
            if let validDate = expiryDate {
                NotificationCenter.default.post(name: .ExpirydateHasBeenSet,
                                                object:nil,
                                                userInfo: [Notification.ExpiryDateHasBeenSetKey:validDate])
            }
        }
    }
    
    @IBOutlet weak var expiryDatePickerView: UIDatePicker!
    
    @IBAction func expiryDatePickerViewChanged(_ sender: UIDatePicker) {
        expiryDate = sender.date
    }
    
}

// Definition:
extension Notification.Name {
    static let ExpirydateHasBeenSet = Notification.Name("ExpiryDatePickerTableViewCell.Notification.ExpiryDateHasBeenSet")
}
