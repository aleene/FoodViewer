//
//  AddNutrientTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 16/01/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

// A cell with a button. The text of the button has to be set by the tableview

class AddNutrientTableViewCell: UITableViewCell {

    internal struct Notification {
        static let AddNutrientButtonTappedKey = "AddNutrientTableViewCell.Notification.AddNutrientButtonTapped.Key"
    }
    

    @IBOutlet weak var addNutrientButton: UIButton! {
        didSet {
            addNutrientButton.setTitle(buttonText, for: .normal )
        }
    }
 
    @IBAction func addNutrientButtonTapped(_ sender: UIButton) {
        let userInfo = [Notification.AddNutrientButtonTappedKey:sender]
        NotificationCenter.default.post(name: .AddNutrientButtonTapped, object: nil, userInfo: userInfo)
    }
    
    var buttonText: String? = nil {
        didSet {
            addNutrientButton?.setTitle(buttonText, for: .normal )
        }
    }
}

// Definition:
extension Notification.Name {
    static let AddNutrientButtonTapped = Notification.Name("AddNutrientTableViewCell.Notification.AddNutrientButtonTapped")
}
