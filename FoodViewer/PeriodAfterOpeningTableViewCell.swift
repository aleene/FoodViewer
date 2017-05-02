//
//  PeriodAfterOpeningTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 30/04/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

class PeriodAfterOpeningTableViewCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.layer.borderWidth = 0.5
            textField.clearButtonMode = .whileEditing
            textField.delegate = delegate
            textField.tag = tag
            setTextFieldStyle()
        }
    }
    
    var tekst: String? = nil {
        didSet {
            if let validTekst = tekst {
                let textParts = validTekst.components(separatedBy: " ")
                if textParts.count == 2 {
                    textField.text = textParts[0]
                    periodLabel.text = textParts[1]
                }
            }
        }
    }
    
    var editMode: Bool = false {
        didSet {
            setTextFieldStyle()
        }
    }
    
    var delegate: SupplyChainTableViewController? = nil {
        didSet {
            textField?.delegate = delegate
        }
    }
    
    override var tag: Int {
        didSet {
            textField?.tag = tag
        }
    }
    
    private func setTextFieldStyle() {
        if editMode {
            textField.backgroundColor = UIColor.groupTableViewBackground
            textField.layer.cornerRadius = 5
            textField.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
            textField.clipsToBounds = true
            
        } else {
            textField.borderStyle = .roundedRect
            textField.backgroundColor = UIColor.white
            textField.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    @IBOutlet weak var periodLabel: UILabel!
}
