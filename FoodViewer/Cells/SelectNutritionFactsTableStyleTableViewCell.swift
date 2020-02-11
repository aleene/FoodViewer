//
//  SelectNutritionFactsTableStyleTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 24/05/2018.
//  Copyright © 2018 Hovering Above. All rights reserved.
//

import UIKit

protocol SelectNutritionFactsTableStyleTableViewControllerCoordinator {
/**
Inform the protocol delegate that no shop has been selected.
 - parameters:
    - sender : the `SelectNutritionFactsTableStyleTableViewController` that called the function.
    - nutrientRow : the row number of that is changed
*/
    func selectNutritionFactsTableStyleTableViewController(_ sender:SelectNutritionFactsTableStyleTableViewController, selected style: NutritionFactsLabelStyle?)
/**
Inform the protocol delegate that no shop has been selected.
 - parameters:
    - sender : the `SelectNutritionFactsTableStyleTableViewController` that called the function.
*/
    func selectNutritionFactsTableStyleTableViewControllerDidCancel(_ sender:SelectNutritionFactsTableStyleTableViewController)
}

class SelectNutritionFactsTableStyleTableViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var coordinator: (Coordinator & SelectNutritionFactsTableStyleTableViewControllerCoordinator)? = nil
    
    public func configure(selected nutritionFactsTableStyle:NutritionFactsLabelStyle?) {
        self.selectedNutritionFactsTableStyle = nutritionFactsTableStyle
    }
//
// MARK: - Internal properties
//
    private var selectedNutritionFactsTableStyle: NutritionFactsLabelStyle? = nil
    
    private var currentNutritionFactsTableStyle: NutritionFactsLabelStyle? = nil
    
    private var sortedStyles: [(NutritionFactsLabelStyle, String)] = []
//
//  MARK : Interface elements
//
    @IBOutlet weak var nutritionFactsTableStylesPickerView: UIPickerView! {
        didSet {
            nutritionFactsTableStylesPickerView.dataSource = self
            nutritionFactsTableStylesPickerView.delegate = self
        }
    }
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBAction func doneBarButtonItemTapped(_ sender: UIBarButtonItem) {
        coordinator?.selectNutritionFactsTableStyleTableViewController(self, selected: selectedNutritionFactsTableStyle)
    }
    
    @IBAction func cancelBarButtonItemTapped(_ sender: UIBarButtonItem) {
        coordinator?.selectNutritionFactsTableStyleTableViewControllerDidCancel(self)
    }
    
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
    
    override func viewDidDisappear(_ animated: Bool) {
        coordinator?.viewControllerDidDisappear(self)
        super.viewDidDisappear(animated)
    }

}


