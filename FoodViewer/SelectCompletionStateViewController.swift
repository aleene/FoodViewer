//
//  SelectCompletionStateViewController.swift
//  FoodViewer
//
//  Created by arnaud on 09/10/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

class SelectCompletionStateViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private struct Storyboard {
        static let UnwindSegue = "Unwind Select Completion State"
    }
    
    var currentCompletion: Completion? = nil
    
    var selectedCompletion: Completion? = nil

// MARK: - Interface elements

    @IBOutlet weak var pickerView: UIPickerView! {
        didSet {
            pickerView.delegate = self
            pickerView.dataSource = self
            pickerView.showsSelectionIndicator = true
        }
    }
    
    @IBOutlet weak var navItem: UINavigationItem!

// MARK: - PickerView Datasource methods
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return OFF.allCompletionStates.count + 1
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
// MARK: - PickerView delegate methods
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "none"
        } else {
            return OFF.allCompletionStates[row - 1].description()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row > 0 {
            selectedCompletion = OFF.allCompletionStates[row - 1]
            performSegue(withIdentifier: Storyboard.UnwindSegue, sender: self)

        }
    }
    
// MARK: - ViewController Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navItem.title = TranslatableStrings.Select
    }
    

}
