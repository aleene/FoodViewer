//
//  SetLastEditDateViewController.swift
//  FoodViewer
//
//  Created by arnaud on 23/10/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//
/*
import UIKit

class SetLastEditDateViewController: UIViewController {
    
    var currentDate: Date? {
        didSet {
            setupInterface()
        }
    }
    
    private func setupInterface() {
        guard datePicker != nil else { return }
        if let validDate = currentDate {
            datePicker.date = validDate
        }
    }
    
    var selectedDate: Date?
    
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBOutlet weak var datePicker: UIDatePicker! {
        didSet {
            setupInterface()
        }
    }
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navItem.title = TranslatableStrings.Select
    }

}
*/
