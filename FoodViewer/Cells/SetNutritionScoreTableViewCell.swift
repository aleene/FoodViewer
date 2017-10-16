//
//  SetNutritionScoreTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 06/10/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

protocol SetNutritionScoreCellDelegate: class {
    // function to let the delegate know that the switch changed
    func firstSegmentedControlToggled(_ sender: UISegmentedControl)
    func secondSegmentedControlToggled(_ sender: UISegmentedControl)
}

class SetNutritionScoreTableViewCell: UITableViewCell {

    @IBOutlet weak var segmentedControl: UISegmentedControl! {
        didSet {
            segmentedControl.setTitle(TranslatableStrings.A, forSegmentAt: 0)
            segmentedControl.setTitle(TranslatableStrings.B, forSegmentAt: 1)
            segmentedControl.setTitle(TranslatableStrings.C, forSegmentAt: 2)
            segmentedControl.setTitle(TranslatableStrings.D, forSegmentAt: 3)
            segmentedControl.setTitle(TranslatableStrings.E, forSegmentAt: 4)
            segmentedControl.setTitle(TranslatableStrings.Undefined, forSegmentAt: 5)

            setLevel()
        }
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        delegate?.firstSegmentedControlToggled(segmentedControl)
    }
    
    @IBOutlet weak var inclusionSegmentedControl: UISegmentedControl! {
        didSet {
            inclusionSegmentedControl.setTitle(TranslatableStrings.Exclude, forSegmentAt: 0)
            inclusionSegmentedControl.setTitle(TranslatableStrings.Include, forSegmentAt: 1)
            inclusionSegmentedControl.selectedSegmentIndex = shouldInclude ? 1 : 0
        }
    }
    
    @IBAction func inclusionSegmentedControlTapped(_ sender: UISegmentedControl) {
        delegate?.secondSegmentedControlToggled(inclusionSegmentedControl)
    }
    
    var shouldInclude = false {
        didSet {
            inclusionSegmentedControl.selectedSegmentIndex = shouldInclude ? 1 : 0
        }
    }
    
    var editMode: Bool = false {
        didSet {
            segmentedControl.isEnabled = editMode
            inclusionSegmentedControl.isEnabled = editMode
        }
    }

    var level: NutritionalScoreLevel = .undefined {
        didSet {
            setLevel()
        }
    }
    
    private func setLevel() {
        switch level {
        case .a:
            segmentedControl.selectedSegmentIndex = 0
        case .b:
            segmentedControl.selectedSegmentIndex = 1
        case .c:
            segmentedControl.selectedSegmentIndex = 2
        case .d:
            segmentedControl.selectedSegmentIndex = 3
        case .e:
            segmentedControl.selectedSegmentIndex = 4
        case .undefined:
            segmentedControl.selectedSegmentIndex = 5
        }
    }
    
    var delegate: SetNutritionScoreCellDelegate? = nil
    
}
