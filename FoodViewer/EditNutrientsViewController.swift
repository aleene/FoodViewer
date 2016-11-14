//
//  EditNutrientsViewController.swift
//  FoodViewer
//
//  Created by arnaud on 10/11/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class EditNutrientsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    var originalNutritionFacts: [NutritionFactItem?]? = nil {
        didSet {
            if originalNutritionFacts != nil {
                if originalNutritionFacts!.count > 0 {
                    currentNutrientItemIndex = 0
                }
            }
        }
    }

    // this is an array with the edited nutrients.
    // if an edit took place the var is no longer nil
    // But only the nutrients that actually changed will get a value
    var editedNutritionFacts: [NutritionFactItem?]? = nil
    
    private func initEditedNutritionFacts() {
        // makes sure the edited array is as large as the original array
        guard originalNutritionFacts != nil else { return }
        
        // do we need to setup something?
        if currentNutrientItemIndex != nil {
            if editedNutritionFacts == nil {
                editedNutritionFacts  = []
            }
            // add a nil nutrient if needed
            if currentNutrientItemIndex! > editedNutritionFacts!.count - 1 {
                for _ in editedNutritionFacts!.count ..< currentNutrientItemIndex! + 1 {
                    editedNutritionFacts!.append(nil)
                }
            }
            editedNutritionFacts?[currentNutrientItemIndex!] = originalNutritionFacts![currentNutrientItemIndex!]
        }
    }
    
    private var currentNutrientItemIndex: Int? = nil {
        didSet {
            // has a valid index been set?
            if originalNutritionFacts != nil && originalNutritionFacts!.count > 0 {
                if currentNutrientItemIndex != nil {
                    // check edges
                    if currentNutrientItemIndex! < 0 {
                        currentNutrientItemIndex = 0
                    } else if currentNutrientItemIndex! > originalNutritionFacts!.count - 1 {
                        currentNutrientItemIndex = originalNutritionFacts!.count - 1
                    }
                } else {
                    // start at the first nutrient
                    currentNutrientItemIndex = 0
                }
                // setup the interface
                setupInterface()
            } else {
                // no valid index is possible
                currentNutrientItemIndex = nil
            }
            setupButtons()
        }
    }
    
    private func setupInterface() {
        if interfaceHasBeenSetup {
            if let index = currentNutrientItemIndex {
                if let validFact = originalNutritionFacts?[index] {
                    nutrientTitle.text = validFact.itemName
                    nutrientValue.text = validFact.standardValue
                    nutrientValue.isEnabled = true
                } else {
                    nutrientValue.isEnabled = false
                }
                // TBD set Unit
                // TBD set model
                // TBD I should show either tht original or the edited values
            }

        }
    }
    
    private var per = NutritionEntryUnit.perStandardUnit {
        didSet {
            switch per {
            case .perStandardUnit:
                nutrientModelSegmentedControl.selectedSegmentIndex = 0
            case .perServing:
                nutrientModelSegmentedControl.selectedSegmentIndex = 1
            }
        }
    }
    
    private var selectedUnit: NutritionFactUnit = .Gram
    
    private var newValue: String? = nil
    
    @IBOutlet weak var nutrientTitle: UILabel! {
        didSet {
            setupInterface()
        }
    }
    
    @IBOutlet weak var nutrientModelSegmentedControl: UISegmentedControl! {
        didSet {
            nutrientModelSegmentedControl.setTitle(NSLocalizedString("Per 100 mg/ml", comment: "Text of 1st segment of a SegmentedControl, indicating the model of the nutrient values, i.e. per standard 100g or 100 ml"), forSegmentAt: 0)
            nutrientModelSegmentedControl.setTitle(NSLocalizedString("Per serving", comment: "Text of 2nd segment of a SegmentedControl, indicating the model of the nutrient values, i.e. the values are indicated per serving"), forSegmentAt: 1)
        }
    }
    @IBAction func nutrientModelSegmentedControlChanged(_ sender: UISegmentedControl) {
        switch nutrientModelSegmentedControl.selectedSegmentIndex {
        case 0:
            per = .perStandardUnit
        case 1:
            per = .perServing
        default:
            break
        }
    }
    
    @IBOutlet weak var nutrient: UILabel! {
        didSet {
            setupInterface()
        }
    }
    
    private var interfaceHasBeenSetup: Bool {
        get {
            return nutrient != nil &&
            nutrientTitle != nil &&
            unitsPickerView != nil &&
            nutrientModelSegmentedControl != nil
        }
    }
    
    // MARK: - PickerView Datasource methods
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 11
        default:
            return 0
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    @IBOutlet weak var unitsPickerView: UIPickerView!
    
    // MARK: - PickerView delegate methods
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return NutritionFactUnit(rawValue: row)?.short()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedUnit = NutritionFactUnit(rawValue: row)!
    }
    
    // MARK: - TextField stuff

    @IBOutlet weak var nutrientValue: UITextField! {
        didSet {
            nutrientValue.delegate = self
            nutrientValue.tag = 0
            setupInterface()
        }
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder { textField.resignFirstResponder() }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 0:
            // nutrient value
            if let validText = textField.text {
                initEditedNutritionFacts()
                editedNutritionFacts![currentNutrientItemIndex!]!.standardValue = validText
            }
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.isFirstResponder { textField.resignFirstResponder() }
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    // MARK: - Button stuff
    
    @IBOutlet weak var previousNutrientItemButton: UIBarButtonItem!
    
    @IBAction func previousNutrientItemTapped(_ sender: UIBarButtonItem) {
        if currentNutrientItemIndex != nil {
            currentNutrientItemIndex! -= 1
        }
    }
    
    @IBOutlet weak var nextNutrientItemButton: UIBarButtonItem!
    
    @IBAction func nextNutrientItemTapped(_ sender: UIBarButtonItem) {
        if currentNutrientItemIndex != nil {
            currentNutrientItemIndex! += 1
        }

    }
    
    private func setupButtons() {
        // set up previous/next buttons
        if currentNutrientItemIndex != nil  {
            previousNutrientItemButton.isEnabled = currentNutrientItemIndex! > 0
            nextNutrientItemButton.isEnabled = currentNutrientItemIndex! < originalNutritionFacts!.count - 1
        } else {
            previousNutrientItemButton.isEnabled = false
            nextNutrientItemButton.isEnabled = false
        }
    }
    
    // MARK: - Segue stuff
    
    @IBAction func unwindAddNutrientForCancel(_ segue:UIStoryboardSegue) {
        // reload with first nutrient?
    }
    
    @IBAction func unwindAddNutrientForDone(_ segue:UIStoryboardSegue) {
        if let vc = segue.source as? AddNutrientViewController {
            var newNutrient = NutritionFactItem()
            newNutrient.itemName = vc.addedNutrientKey
            // is this the first nutritionFact?
            if originalNutritionFacts == nil {
                originalNutritionFacts = []
            }
            originalNutritionFacts!.append(newNutrient)
            // move to the newly added nutrient
            currentNutrientItemIndex = originalNutritionFacts!.count - 1
        }
    }
    
    // MARK: - ViewController lifecycle stuff

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Edit Nutrient", comment: "Title of view controller, which allows editing of the nutrients")
        per = .perStandardUnit
        nutrientValue.delegate = self
        unitsPickerView.delegate = self
        unitsPickerView.dataSource = self
        nutrientValue.isEnabled = false
        nutrientTitle.text = NSLocalizedString("No nutrients", comment: "Text of Label, indicating that the product has no nutrients defined")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupButtons()
        setupInterface()
    }
}
