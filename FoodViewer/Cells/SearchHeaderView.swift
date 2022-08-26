//
//  SearchHeaderView.swift
//  FoodViewer
//
//  Created by arnaud on 24/10/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit


protocol SearchHeaderDelegate: AnyObject {
    func sortButtonTapped(_ sender: SearchHeaderView, button: UIButton)
    func clearButtonTapped(_ sender: SearchHeaderView, button: UIButton)
}

class SearchHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var sortButton: UIButton! {
        didSet {
            sortButton.isEnabled = sortButtonIsEnabled && buttonsAreEnabled
        }
    }
    
    @IBAction func sortButtonTapped(_ sender: UIButton) {
        delegate?.sortButtonTapped(self, button: sender)
    }
    
    @IBOutlet weak var clearButton: UIButton! {
        didSet {
            clearButton.isEnabled = sortButtonIsEnabled && buttonsAreEnabled
        }
    }
    
    @IBAction func clearButtonTapped(_ sender: UIButton) {
        delegate?.clearButtonTapped(self, button: sender)
    }

    @IBOutlet weak var label: UILabel!

    weak var delegate: SearchHeaderDelegate?
    
    var title: String? = nil {
        didSet {
            label.text = title
        }
    }
    
    var sortButtonIsEnabled = false {
        didSet {
            sortButton.isEnabled = sortButtonIsEnabled && buttonsAreEnabled
        }
    }
    
    var buttonsAreEnabled = false {
        didSet {
            clearButton.isEnabled = buttonsAreEnabled
        }
    }

}
