//
//  NutrimentsAvailableTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 23/01/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

//  TableViewCell, which contains a label and a switch
//  The switch indicates whether any nutriment information is available on the package
//  Default is NO nutriment info available
//  If the cell is in editMode (true), the switch is enabled

import UIKit

class NutrimentsAvailableTableViewCell: UITableViewCell {

    internal struct Notification {
        static let NutrimentsAvailability = "NutrimentsAvailableTableViewCell.Notification.NutrimentsAvailability.Key"
    }


    @IBOutlet weak var NutrimentsAvailableSwitch: UISwitch! {
        didSet {
            NutrimentsAvailableSwitch.isOn = hasNutrimentFacts ?? false
            NutrimentsAvailableSwitch.isEnabled = editMode
        }
    }
    
    @IBAction func NutrimentsAvailableSwitchTapped(_ sender: UISwitch) {
        let data = [Notification.NutrimentsAvailability: NutrimentsAvailableSwitch.isOn]
        NotificationCenter.default.post(name: .NutrimentsAvailabilityTapped, object:nil, userInfo: data)
    }
    
    var hasNutrimentFacts: Bool? = nil {
        didSet {
            NutrimentsAvailableSwitch?.isOn = hasNutrimentFacts ?? false
        }
    }
    
    var editMode = false {
        didSet {
            NutrimentsAvailableSwitch?.isEnabled = editMode
        }
    }
}

// Definition:
extension Notification.Name {
    static let NutrimentsAvailabilityTapped = Notification.Name("NutrimentsAvailableTableViewCell.Notification.NutrimentsAvailabilityTapped")
}
