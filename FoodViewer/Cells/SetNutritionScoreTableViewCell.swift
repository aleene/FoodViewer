//
//  SetNutritionScoreTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 06/10/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

class SetNutritionScoreTableViewCell: UITableViewCell {

    @IBOutlet weak var segmentedControl: UISegmentedControl! {
        didSet {
            segmentedControl.setTitle("A", forSegmentAt: 0)
            segmentedControl.setTitle("B", forSegmentAt: 1)
            segmentedControl.setTitle("C", forSegmentAt: 2)
            segmentedControl.setTitle("D", forSegmentAt: 3)
            segmentedControl.setTitle("E", forSegmentAt: 4)
            segmentedControl.setTitle("Undefined", forSegmentAt: 5)

            setLevel()
        }
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            delegate?.setLevel(NutritionalScoreLevel.a)
        case 1:
            delegate?.setLevel(NutritionalScoreLevel.b)
        case 2:
            delegate?.setLevel(NutritionalScoreLevel.c)
        case 3:
            delegate?.setLevel(NutritionalScoreLevel.d)
        case 4:
            delegate?.setLevel(NutritionalScoreLevel.e)
        case 5:
            delegate?.setLevel(NutritionalScoreLevel.undefined)
        default:
            break
        }
    }
    
    var editMode: Bool = false {
        didSet {
            segmentedControl.isEnabled = editMode
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
    
    var delegate: NutritionScoreTableViewController? = nil
    
}
