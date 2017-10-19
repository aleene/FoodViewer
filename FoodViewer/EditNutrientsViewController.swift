//
//  EditNutrientsViewController.swift
//  FoodViewer
//
//  Created by arnaud on 10/11/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit

class EditNutrientsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    fileprivate struct Storyboard {
        static let SegueIdentifier = "Unwind Edit Nutrients For Done Segue"
    }

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
            // is this the first edit on this nutrient?
            if editedNutritionFacts![currentNutrientItemIndex!] == nil {
                editedNutritionFacts![currentNutrientItemIndex!] = originalNutritionFacts![currentNutrientItemIndex!]
            }
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
            if interfaceHasBeenSetup {
                setupButtons()
            }
        }
    }
    
    private func setupInterface() {
        if interfaceHasBeenSetup {
            if let index = currentNutrientItemIndex {
                if let validFact = originalNutritionFacts?[index] {
                    nutrientTitle.text = validFact.itemName
                    nutrientValue.text = validFact.standardValue
                    if let row = validFact.standardValueUnit?.rawValue {
                        unitsPickerView.selectRow(row, inComponent: 0, animated: false)
                    } else {
                        unitsPickerView.selectRow(0, inComponent: 0, animated: false)
                    }
                    nutrientValue.isEnabled = true
                } else {
                    nutrientValue.isEnabled = false
                }
                // TBD set model
                // TBD I should show either tht original or the edited values
                // set up previous/next buttons
                if currentNutrientItemIndex != nil  {
                    previousNutrientItemButton.isEnabled = currentNutrientItemIndex! > 0
                    nextNutrientItemButton.isEnabled = currentNutrientItemIndex! < originalNutritionFacts!.count - 1
                } else {
                    previousNutrientItemButton.isEnabled = false
                    nextNutrientItemButton.isEnabled = false
                }
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
    
    @IBOutlet weak var nutrientTitle: UILabel! {
        didSet {
            setupInterface()
        }
    }
    
    @IBOutlet weak var nutrientModelSegmentedControl: UISegmentedControl! {
        didSet {
            nutrientModelSegmentedControl.setTitle(TranslatableStrings.Per100mgml, forSegmentAt: 0)
            nutrientModelSegmentedControl.setTitle(TranslatableStrings.PerServing, forSegmentAt: 1)
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
            nutrientModelSegmentedControl != nil &&
            previousNutrientItemButton != nil &&
            nextNutrientItemButton != nil
        }
    }
    
    // MARK: - PickerView Datasource methods
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return NutritionFactUnit.countCases()
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
        initEditedNutritionFacts()
        if per == .perStandardUnit {
            editedNutritionFacts![currentNutrientItemIndex!]?.standardValueUnit = NutritionFactUnit(rawValue: row)!
        } else {
            editedNutritionFacts![currentNutrientItemIndex!]?.servingValueUnit = NutritionFactUnit(rawValue: row)!
        }
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
                if per == .perStandardUnit {
                    editedNutritionFacts![currentNutrientItemIndex!]!.standardValue = validText
                } else {
                    editedNutritionFacts![currentNutrientItemIndex!]!.servingValue = validText
                }
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
    
    
    // MARK: - ViewController lifecycle stuff

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.title = TranslatableStrings.EditNutrient
        per = .perStandardUnit
        nutrientTitle.text = TranslatableStrings.NoNutrients
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nutrientValue.delegate = self
        unitsPickerView.delegate = self
        unitsPickerView.dataSource = self
        unitsPickerView.selectRow(0, inComponent: 0, animated: false)
        nutrientValue.isEnabled = false

        // setupButtons()
        setupInterface()
    }
}
