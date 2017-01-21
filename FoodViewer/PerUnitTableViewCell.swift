//
//  PerUnitTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 20/01/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit
import Foundation

class PerUnitTableViewCell: UITableViewCell {

    internal struct Notification {
        static let PerUnitHasBeenSetKey = "PerUnitTableViewCell.Notification.PerUnitHasBeenSetKey.Key"
    }

    @IBOutlet weak var perUnitSegmentedControl: UISegmentedControl!
    
    @IBAction func PerUnitSegmentedControlTapped(_ sender: UISegmentedControl) {
        // send a notification to indicate a change has occurred
        // and include the segment that has been changed
        // 0 is perStandard
        // 1 is perPortion
        notifyUser()
    }
    
    var displayMode: NutritionDisplayMode = .perStandard {
        didSet {
            switch displayMode {
            case .perStandard:
                perUnitSegmentedControl.selectedSegmentIndex = 0
            case .perServing:
                perUnitSegmentedControl.selectedSegmentIndex = 1
            case .perDailyValue:
                perUnitSegmentedControl.selectedSegmentIndex = 2
            }
        }
    }
    
    func notifyUser() {
        if let index = perUnitSegmentedControl?.selectedSegmentIndex {
            let data = [Notification.PerUnitHasBeenSetKey: index]
            NotificationCenter.default.post(name: .PerUnitChanged, object:nil, userInfo: data)
        }
    }
}

// Definition:
extension Notification.Name {
    static let PerUnitChanged = Notification.Name("PerUnitTableViewCell.Notification.PerUnitChanged")
}
