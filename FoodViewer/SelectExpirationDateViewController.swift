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
            setupInterface()
        }
    }
    
    private func setupInterface() {
        if expirationDatePicker != nil {
            if let validDate = currentDate {
                expirationDatePicker.date = validDate
            }
        }
    }
    
    var selectedDate: Date?
    
    @IBOutlet weak var expirationDatePicker: UIDatePicker! {
        didSet {
            setupInterface()
        }
    }
    
    @IBAction func expirationDatePickerChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.title = TranslatableStrings.Select
    }
    
}
