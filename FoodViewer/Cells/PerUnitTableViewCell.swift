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

    private enum PerUnitSegment: Int {
        case hectogram = 0
        case kilogram = 1
        case serving = 2
        case dailyValue = 3
    }
// MARK: - interface elements
    
    @IBOutlet weak var perUnitSegmentedControl: UISegmentedControl! {
        didSet {
            perUnitSegmentedControl.setTitle(TranslatableStrings.Per100mgml, forSegmentAt: PerUnitSegment.hectogram.rawValue)
            perUnitSegmentedControl.setTitle(TranslatableStrings.PerServing, forSegmentAt: PerUnitSegment.serving.rawValue)
            perUnitSegmentedControl.setTitle(TranslatableStrings.PerDailyValue, forSegmentAt: PerUnitSegment.dailyValue.rawValue)
            perUnitSegmentedControl.setTitle(TranslatableStrings.PerKilogram, forSegmentAt: PerUnitSegment.kilogram.rawValue)
        }
    }
    
    @IBAction func PerUnitSegmentedControlTapped(_ sender: UISegmentedControl) {
        // call the delegate to indicate a change has occurred
        // and include the segment that has been changed
        // 0 is perStandard
        // 1 is perPortion in mg
        // 2 is perPortion in daily value percentage
        delegate?.perUnitTableViewCell(self, receivedActionOn: perUnitSegmentedControl)
    }
    
// MARK: - public functions
    
    public func setup(nutritionFactsAvailability: NutritionAvailability?,
                      displayMode: NutritionDisplayMode,
                      editMode: Bool,
                      delegate: PerUnitCellDelegate) {
        self.nutritionFactsAvailability = nutritionFactsAvailability
        self.displayMode = displayMode
        self.editMode = editMode
        self.delegate = delegate
        
        setSelectedSegment()
        setSegmentEnabledState()
    }
    
// MARK: - private setup variables
    
    private var displayMode: NutritionDisplayMode = .perStandard
    
    private var editMode = false
    
    private var nutritionFactsAvailability: NutritionAvailability? = nil
        
    private var delegate: PerUnitCellDelegate? = nil
    
// MARK: - private functions
    
    private func setSelectedSegment() {
        // set the selected segment at start up
        // this depends however on the availablity
        switch displayMode {
        case .perStandard:
            if let validAvailability = nutritionFactsAvailability {
                switch validAvailability {
                case .perServingAndStandardUnit, .perStandardUnit:
                    perUnitSegmentedControl.selectedSegmentIndex = PerUnitSegment.hectogram.rawValue
                case .perServing:
                    perUnitSegmentedControl.selectedSegmentIndex = PerUnitSegment.serving.rawValue
                default: break
                }
            }
        case .perThousandGram:
            if let validAvailability = nutritionFactsAvailability {
                switch validAvailability {
                case .perServingAndStandardUnit, .perStandardUnit:
                    perUnitSegmentedControl.selectedSegmentIndex = PerUnitSegment.kilogram.rawValue
                case .perServing:
                    // need to fall back
                    perUnitSegmentedControl.selectedSegmentIndex = PerUnitSegment.serving.rawValue
                default: break
                }
            }
        case .perServing:
            if let validAvailability = nutritionFactsAvailability {
                switch validAvailability {
                case .perStandardUnit:
                    perUnitSegmentedControl.selectedSegmentIndex = PerUnitSegment.hectogram.rawValue
                case .perServing, .perServingAndStandardUnit:
                    perUnitSegmentedControl.selectedSegmentIndex = PerUnitSegment.serving.rawValue
                default: break
                }
            }
        case .perDailyValue:
            if let validAvailability = nutritionFactsAvailability {
                switch validAvailability {
                case .perStandardUnit:
                    perUnitSegmentedControl.selectedSegmentIndex = PerUnitSegment.hectogram.rawValue
                case .perServing, .perServingAndStandardUnit:
                    perUnitSegmentedControl.selectedSegmentIndex = PerUnitSegment.dailyValue.rawValue
                default: break
                }
            }
        }
    }
    
    private func setSegmentEnabledState() {
        
        if editMode {
            // in editMode the user can enter the data in any way he wants
            perUnitSegmentedControl.isEnabled = true
            perUnitSegmentedControl.isEnabledForSegment(at: PerUnitSegment.hectogram.rawValue)
            perUnitSegmentedControl.isEnabledForSegment(at: PerUnitSegment.kilogram.rawValue)
            perUnitSegmentedControl.isEnabledForSegment(at: PerUnitSegment.serving.rawValue)
            perUnitSegmentedControl.isEnabledForSegment(at: PerUnitSegment.dailyValue.rawValue)
        } else {
            // Are any nutrition facts set?
            if let validAvailability = nutritionFactsAvailability {
                perUnitSegmentedControl.isEnabled = false
                // The segment that is shown depends on the available data
                // We (should) trust here the OFF analysis
                // either per 100g or per serving/daily value
                // everything if there is a (readible) serving, which allows for conversion
                switch validAvailability {
                case .perServingAndStandardUnit:
                    // all segments are enabled
                    perUnitSegmentedControl.isEnabled = true
                case .perServing:
                    // only the per serving sections are enables
                    perUnitSegmentedControl.isEnabledForSegment(at: PerUnitSegment.serving.rawValue)
                    perUnitSegmentedControl.isEnabledForSegment(at: PerUnitSegment.dailyValue.rawValue)
                case .perStandardUnit:
                    // the per standard unit and kg section are enabled
                    perUnitSegmentedControl.isEnabledForSegment(at: PerUnitSegment.hectogram.rawValue)
                    perUnitSegmentedControl.isEnabledForSegment(at: PerUnitSegment.kilogram.rawValue)
                default:
                    perUnitSegmentedControl.isEnabled = false
                }
            } else {
                // No nutrition facts available,
                // the segemented control can be disabled (or even hidden)
                perUnitSegmentedControl.isEnabled = false
            }
        }
    }
}
