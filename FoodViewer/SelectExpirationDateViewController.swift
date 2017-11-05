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
    
    @IBOutlet weak var navItem: UINavigationItem!

    
    // MARK: - ViewController Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navItem.title = TranslatableStrings.Select
    }

}
