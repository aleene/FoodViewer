//
//  SelectNutritionFactsTableStyleTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 24/05/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import UIKit

class SelectNutritionFactsTableStyleTableViewCell: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - External properties
    
    var selectedNutritionFactsTableStyle: NutritionFactsLabelStyle? = nil
    
    var currentNutritionFactsTableStyle: NutritionFactsLabelStyle? = nil
    
    var editMode: Bool = false
    
    // MARK: - Internal properties
    
    private var sortedStyles: [(NutritionFactsLabelStyle, String)] = []
    
    //  MARK : Interface elements
    
    @IBOutlet weak var nutritionFactsTableStylesPickerView: UIPickerView! {
        didSet {
            nutritionFactsTableStylesPickerView.dataSource = self
            nutritionFactsTableStylesPickerView.delegate = self
        }
    }
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    // MARK: - Delegates and datasource
    
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedNutritionFactsTableStyle = row > 0 ? sortedStyles[row - 1].0 : nil
    }
    
    
    internal func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    internal func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sortedStyles.count + 1
    }
    
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if row == 0 {
            return "---"
        } else {
            return sortedStyles[row - 1].1
        }
    }
    
    private func setupStyles() {
        var allStyles: [(NutritionFactsLabelStyle, String)] = []
        for style in NutritionFactsLabelStyle.allStyles {
            allStyles.append((style, style.description))
        }
        sortedStyles = allStyles.sorted(by: forward)
    }
    
    private func forward(_ s1: (NutritionFactsLabelStyle, String), _ s2: (NutritionFactsLabelStyle, String)) -> Bool {
        return s1.1 < s2.1
    }
    
    // MARK: - ViewController Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navItem.title = TranslatableStrings.Select
        setupStyles()
    }
    
}


