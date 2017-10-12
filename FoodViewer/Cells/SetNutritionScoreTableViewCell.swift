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
            segmentedControl.setTitle(TranslatableStrings.TableViewCell.SetNutritionScore.A, forSegmentAt: 0)
            segmentedControl.setTitle(TranslatableStrings.TableViewCell.SetNutritionScore.B, forSegmentAt: 1)
            segmentedControl.setTitle(TranslatableStrings.TableViewCell.SetNutritionScore.C, forSegmentAt: 2)
            segmentedControl.setTitle(TranslatableStrings.TableViewCell.SetNutritionScore.D, forSegmentAt: 3)
            segmentedControl.setTitle(TranslatableStrings.TableViewCell.SetNutritionScore.E, forSegmentAt: 4)
            segmentedControl.setTitle(TranslatableStrings.TableViewCell.SetNutritionScore.Undefined, forSegmentAt: 5)

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
    
    @IBOutlet weak var inclusionSegmentedControl: UISegmentedControl! {
        didSet {
            inclusionSegmentedControl.setTitle(TranslatableStrings.TableViewCell.SetNutritionScore.Exclude, forSegmentAt: 0)
            inclusionSegmentedControl.setTitle(TranslatableStrings.TableViewCell.SetNutritionScore.Include, forSegmentAt: 1)
            inclusionSegmentedControl.selectedSegmentIndex = shouldInclude ? 1 : 0
        }
    }
    
    @IBAction func inclusionSegmentedControlTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            shouldInclude = false
        case 1:
            shouldInclude = true
        default:
            break
        }
        delegate?.setShouldInclude(shouldInclude)
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
    
    var delegate: NutritionScoreTableViewController? = nil
    
}
