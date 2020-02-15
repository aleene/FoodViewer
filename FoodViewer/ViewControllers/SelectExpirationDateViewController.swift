//
//  SelectExpirationDateViewController.swift
//  FoodViewer
//
//  Created by arnaud on 10/11/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

protocol SelectExpirationDateViewControllerCoordinator {
/**
Inform the protocol delegate that no data has been selected.
- Parameters:
    - sender : the `SelectExpirationDateViewController` that called the function.
*/
    func selectExpirationDateViewControllerDidCancel(_ sender:SelectExpirationDateViewController)
/**
Inform the protocol delegate that a date has been selected.
- Parameters:
    - sender : the `SelectExpirationDateViewController` that called the function.
    - date : the selected date
*/
    func selectExpirationDateViewController(_ sender:SelectExpirationDateViewController, selected date:Date?)

}

class SelectExpirationDateViewController: UIViewController {
    
    var currentDate: Date? {
        didSet {
            setupInterface()
        }
    }
    
    var coordinator: (SelectExpirationDateViewControllerCoordinator & Coordinator)? = nil
    
    private func setupInterface() {
        if expirationDatePicker != nil {
            if let validDate = currentDate {
                expirationDatePicker.date = validDate
            }
        }
    }
    
    private var selectedDate: Date?
    
    @IBOutlet weak var expirationDatePicker: UIDatePicker! {
        didSet {
            setupInterface()
        }
    }
    
    @IBAction func expirationDatePickerChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }
    
    @IBOutlet weak var navItem: UINavigationItem!

    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        coordinator?.selectExpirationDateViewControllerDidCancel(self)
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        coordinator?.selectExpirationDateViewController(self, selected: selectedDate)
    }
    
    // MARK: - ViewController Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navItem.title = TranslatableStrings.Select
    }

    override func viewDidDisappear(_ animated: Bool) {
        coordinator?.viewControllerDidDisappear(self)
        super.viewDidDisappear(animated)
    }
}
