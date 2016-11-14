//
//  SelectExpirationDateViewController.swift
//  FoodViewer
//
//  Created by arnaud on 10/11/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class SelectExpirationDateViewController: UIViewController {
    
    var currentDate: Date? {
        didSet {
            if let validDate = currentDate {
                expirationDatePicker.date = validDate
            }
        }
    }
    
    var selectedDate: Date?
    
    @IBOutlet weak var expirationDatePicker: UIDatePicker!
    
    @IBAction func expirationDatePickerChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }
    
}
