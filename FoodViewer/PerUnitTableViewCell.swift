//
//  PerUnitTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 20/01/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

protocol PerUnitCellDelegate: class {
    
    // function to let the delegate know that the switch changed
    func perUnitTableViewCell(_ sender: PerUnitTableViewCell, receivedActionOn segmentedControl:UISegmentedControl)
}

class PerUnitTableViewCell: UITableViewCell {

    @IBOutlet weak var perUnitSegmentedControl: UISegmentedControl! {
        didSet {
            perUnitSegmentedControl.setTitle(TranslatableStrings.Per100mgml, forSegmentAt: 0)
            perUnitSegmentedControl.setTitle(TranslatableStrings.PerServing, forSegmentAt: 1)
        }
    }
    
    @IBAction func PerUnitSegmentedControlTapped(_ sender: UISegmentedControl) {
        // call the delegate to indicate a change has occurred
        // and include the segment that has been changed
        // 0 is perStandard
        // 1 is perPortion
        delegate?.perUnitTableViewCell(self, receivedActionOn: perUnitSegmentedControl)
    }
    
    var displayMode: NutritionDisplayMode = .perStandard {
        didSet {
            setView()
        }
    }
    
    var editMode = false {
        didSet {
            setView()
        }
    }
    
    var nutritionFactsAvailability: NutritionAvailability? = nil {
        didSet {
            setView()
        }
    }
    
    var delegate: PerUnitCellDelegate? = nil
    
    private func setView() {
        switch displayMode {
        case .perStandard, .perThousandGram :
            perUnitSegmentedControl.selectedSegmentIndex = 0
        case .perServing:
            perUnitSegmentedControl.selectedSegmentIndex = 1
        case .perDailyValue:
            perUnitSegmentedControl.selectedSegmentIndex = 0
        }
        if editMode {
            perUnitSegmentedControl.isEnabled = true
        } else {
            if let validAvailability = nutritionFactsAvailability {
                perUnitSegmentedControl.isEnabled = false
                // what is possible?
                switch validAvailability {
                case .perServingAndStandardUnit:
                    perUnitSegmentedControl.isEnabled = true
                case .perServing:
                    perUnitSegmentedControl.isEnabledForSegment(at: 1)
                    //perUnitSegmentedControl.selectedSegmentIndex = 1
                case .perStandardUnit:
                    perUnitSegmentedControl.isEnabledForSegment(at: 0)
                    //perUnitSegmentedControl.selectedSegmentIndex = 0
                default:
                    break
                }
            }
        }
    }
}
