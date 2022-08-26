//
//  PreparationStyleTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 31/12/2020.
//  Copyright © 2020 Hovering Above. All rights reserved.
//

import UIKit

protocol PreparationStyleCellDelegate: AnyObject {
    
    // function to let the delegate know that the switch changed
    func preparationStyleTableViewCell(_ sender: PreparationStyleTableViewCell, receivedActionOn segmentedControl: UISegmentedControl)
}

class PreparationStyleTableViewCell: UITableViewCell {

    @IBOutlet weak var preparationStyleSegmentedControl: UISegmentedControl! {
        didSet {
            preparationStyleSegmentedControl.setTitle(NutritionFactsPreparationStyle.unprepared.description, forSegmentAt: NutritionFactsPreparationStyle.unprepared.rawValue)
            preparationStyleSegmentedControl.setTitle(NutritionFactsPreparationStyle.prepared.description, forSegmentAt: NutritionFactsPreparationStyle.prepared.rawValue)
        }
    }
    
    @IBAction func preparationStyleSegmentedControlTapped(_ sender: UISegmentedControl) {
        delegate?.preparationStyleTableViewCell(self, receivedActionOn: preparationStyleSegmentedControl)
    }
    
// MARK: - public functions
    
    public func setup(currentPreparationStyle: NutritionFactsPreparationStyle,
                      availability: (Bool, Bool),
                      editMode: Bool,
                      delegate: PreparationStyleCellDelegate) {
        self.currentPreparationStyle = currentPreparationStyle
        self.editMode = editMode
        self.availability = availability
        self.delegate = delegate
        
        setSelectedSegment()
        setSegmentEnabledState()
    }
    
// MARK: - private setup variables
    
    private var currentPreparationStyle: NutritionFactsPreparationStyle = .unprepared
    
    private var editMode = false
    
    private var availability: (Bool, Bool) = (false, false)
            
    private var delegate: PreparationStyleCellDelegate? = nil
    
// MARK: - private functions
    
    private func setSelectedSegment() {
        // set the selected segment at start up
        // this depends however on the availablity
        switch currentPreparationStyle {
        case .unprepared:
            preparationStyleSegmentedControl.selectedSegmentIndex = NutritionFactsPreparationStyle.unprepared.rawValue
        case .prepared:
            preparationStyleSegmentedControl.selectedSegmentIndex = NutritionFactsPreparationStyle.prepared.rawValue
        }
    }
    
    private func setSegmentEnabledState() {
        
        if editMode {
            // in editMode the user can enter the data in any way he wants
            preparationStyleSegmentedControl.setEnabled(true, forSegmentAt: NutritionFactsPreparationStyle.unprepared.rawValue)
            preparationStyleSegmentedControl.setEnabled(true, forSegmentAt: NutritionFactsPreparationStyle.prepared.rawValue)
        } else {
            preparationStyleSegmentedControl.setEnabled(availability.0, forSegmentAt: NutritionFactsPreparationStyle.unprepared.rawValue)
            preparationStyleSegmentedControl.setEnabled(availability.1, forSegmentAt: NutritionFactsPreparationStyle.prepared.rawValue)
        }
    }
}

