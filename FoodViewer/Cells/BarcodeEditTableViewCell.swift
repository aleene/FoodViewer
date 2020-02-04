//
//  BarcodeEditTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 15/09/2017.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import UIKit

protocol BarcodeEditCellDelegate: class {
    
/// function to let the delegate know that the switch changed
    func barcodeEditTableViewCell(_ sender: BarcodeEditTableViewCell, receivedActionOn segmentedControl:UISegmentedControl)
}

class BarcodeEditTableViewCell: UITableViewCell {


    @IBOutlet weak var barcodeTextField: UITextField! {
        didSet {
            barcodeTextField.layer.borderWidth = 0.5
            barcodeTextField.clearButtonMode = .whileEditing
            barcodeTextField.delegate = delegate as? UITextFieldDelegate
            barcodeTextField.tag = tag
            setTextFieldStyle()
        }
    }

    @IBOutlet weak var segmentedControl: UISegmentedControl! {
        didSet {
            segmentedControl.setTitle("EAN-8", forSegmentAt: 0)
            segmentedControl.setTitle("UPC-12", forSegmentAt: 1)
            segmentedControl.setTitle("EAN-13", forSegmentAt: 2)
            segmentedControl.isEnabled = barcode != nil ? true : false
        }
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        delegate?.barcodeEditTableViewCell(self, receivedActionOn: sender)
    }
 
    var barcode: BarcodeType? = nil {
        didSet {
            if let validBarcode = barcode {
                barcodeTextField.text = validBarcode.asString
                switch validBarcode {
                case .upc12:
                    segmentedControl.selectedSegmentIndex = 1
                case .ean13:
                    segmentedControl.selectedSegmentIndex = 2
                default:
                    segmentedControl.selectedSegmentIndex = 0
                }

            }
            
            segmentedControl?.isEnabled = editMode
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

    var delegate: BarcodeEditCellDelegate? = nil {
        didSet {
            barcodeTextField?.delegate = delegate as? UITextFieldDelegate
        }
    }

    private func setTextFieldStyle() {
        if editMode {
            barcodeTextField.backgroundColor = UIColor.groupTableViewBackground
            barcodeTextField.layer.cornerRadius = 5
            barcodeTextField.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
            barcodeTextField.clipsToBounds = true
            segmentedControl.isEnabled = true
            
        } else {
            barcodeTextField.borderStyle = .roundedRect
            barcodeTextField.backgroundColor = UIColor.white
            barcodeTextField.layer.borderColor = UIColor.white.cgColor
        }
        segmentedControl?.isEnabled = editMode
    }

}
