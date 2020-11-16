//
//  SelectNutrientUnitViewController.swift
//  FoodViewer
//
//  Created by arnaud on 16/01/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

protocol SelectNutrientCoordinatorProtocol {
    /**
    Inform the protocol delegate that no shop has been selected.
    - Parameters:
         - sender : the `SelectNutrientUnitViewController` that called the function.
         - nutrientRow : the row number of that is changed
    */
    func selectNutrientUnitViewController(_ sender:SelectNutrientUnitViewController, nutrient:Nutrient?, unit:NutritionFactUnit?)
    /**
    Inform the protocol delegate that no shop has been selected.
    - Parameters:
         - sender : the `SelectNutrientUnitViewController` that called the function.
    */
    func selectNutrientUnitViewControllerDidCancel(_ sender:SelectNutrientUnitViewController)
}

class SelectNutrientUnitViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var protocolCoordinator: SelectNutrientCoordinatorProtocol? = nil
    
    weak var coordinator: Coordinator? = nil

    private struct Constants {
        //static let UnwindSegue = "Unwind Set Nutrient Unit"
        static let RowOffset = 1
    }
    
    public func configure(nutrient: Nutrient?, unit: NutritionFactUnit?) {
        self.currentNutrient = nutrient
        self.currentNutritionUnit = unit
    }
    
    private var energyUnit: Bool {
        guard let validNutrient = currentNutrient else { return false }
        switch validNutrient {
        case .energy ,.energyKcal, .energyFromFat:
            return true
        default:
            return false
        }
    }
    
    private var currentNutrient: Nutrient? = nil
    
    private var currentNutritionUnit: NutritionFactUnit? = nil
        
    private var selectedNutritionUnit: NutritionFactUnit? = nil
    
    @IBOutlet weak var nutrientUnitsPickerView: UIPickerView! {
        didSet {
            nutrientUnitsPickerView?.delegate = self
            nutrientUnitsPickerView?.dataSource = self
            nutrientUnitsPickerView?.showsSelectionIndicator = true
        }
    }
    
    @IBOutlet weak var navItem: UINavigationItem!

    @IBAction func doneBarButtonItemTapped(_ sender: UIBarButtonItem) {
        protocolCoordinator?.selectNutrientUnitViewController(self, nutrient: currentNutrient, unit: selectedNutritionUnit)
    }
    
    @IBAction func cancelBarButtonItemTapped(_ sender: UIBarButtonItem) {
        protocolCoordinator?.selectNutrientUnitViewControllerDidCancel(self)
    }

// MARK: - PickerView Datasource methods
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return NutritionFactUnit.units(for:energyUnit).count + Constants.RowOffset
        default:
            return 0
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
// MARK: - PickerView delegate methods
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return row >= Constants.RowOffset ? NutritionFactUnit.units(for:energyUnit)[row - Constants.RowOffset].short : ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row >= Constants.RowOffset {
            selectedNutritionUnit = NutritionFactUnit.units(for:energyUnit)[row - Constants.RowOffset]
            protocolCoordinator?.selectNutrientUnitViewController(self, nutrient: currentNutrient, unit: selectedNutritionUnit)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navItem.title = TranslatableStrings.Select
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        coordinator?.viewControllerDidDisappear(self)
        super.viewDidDisappear(animated)
    }

}
