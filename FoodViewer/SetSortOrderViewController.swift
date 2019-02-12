//
//  SetSortOrderViewController.swift
//  FoodViewer
//
//  Created by arnaud on 25/10/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

class SetSortOrderViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private struct Constant {
        static let RowOffset = 1
    }
    
    // MARK: - External properties
    
    var selectedSortOrder: SearchSortOrder? = nil
    
    var currentSortOrder: SearchSortOrder? = nil {
        didSet {
            if let validCurrentSortOrder = currentSortOrder,
                let selectedRow = SearchSortOrder.all.index(where: { $0 == validCurrentSortOrder } ) {
                //pickerView.selectRow(selectedRow + Constant.RowOffset, inComponent: 0, animated: false)
            } 
        }
    }
    
    //  MARK : Interface elements
    
    @IBOutlet weak var pickerView: UIPickerView! {
        didSet {
            pickerView.dataSource = self
            pickerView.delegate = self
        }
    }
    
    @IBOutlet weak var navItem: UINavigationItem!

    // MARK: - Delegates and datasource
    
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedSortOrder = row > 0 ? SearchSortOrder.all[row - Constant.RowOffset] : nil
    }
    
    
    internal func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    internal func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return SearchSortOrder.all.count + 1
    }
    
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if row == 0 {
            return "---"
        } else {
            return SearchSortOrder.all[row - Constant.RowOffset].description
        }
    }
    
    private var descriptions: [String] {
        return SearchSortOrder.all.map { $0.description } .sorted()
    }

    // MARK: - ViewController Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navItem.title = TranslatableStrings.Select
    }

}
