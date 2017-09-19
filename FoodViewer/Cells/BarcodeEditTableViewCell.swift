//
//  BarcodeEditTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 15/09/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

class BarcodeEditTableViewCell: UITableViewCell {


    @IBOutlet weak var barcodeTextField: UITextField! {
        didSet {
            barcodeTextField.layer.borderWidth = 0.5
            barcodeTextField.clearButtonMode = .whileEditing
            barcodeTextField.delegate = delegate
            barcodeTextField.tag = tag
            setTextFieldStyle()
        }
    }

    
    var barcode: String? = nil {
        didSet {
            if let validBarcode = barcode {
                barcodeTextField.text = validBarcode
            }
        }
    }
    
    override var tag: Int {
        didSet {
            barcodeTextField?.tag = tag
        }
    }

    var editMode: Bool = false {
        didSet {
            setTextFieldStyle()
        }
    }

    var delegate: IdentificationTableViewController? = nil {
        didSet {
            barcodeTextField?.delegate = delegate
        }
    }

    private func setTextFieldStyle() {
        if editMode {
            barcodeTextField.backgroundColor = UIColor.groupTableViewBackground
            barcodeTextField.layer.cornerRadius = 5
            barcodeTextField.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
            barcodeTextField.clipsToBounds = true
            
        } else {
            barcodeTextField.borderStyle = .roundedRect
            barcodeTextField.backgroundColor = UIColor.white
            barcodeTextField.layer.borderColor = UIColor.white.cgColor
        }
    }

}
