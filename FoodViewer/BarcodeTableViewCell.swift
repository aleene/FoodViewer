//
//  BarcodeTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 24/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import AVFoundation

class BarcodeTableViewCell: UITableViewCell {

    var barcode: String? = nil {
        didSet {
            if let validBarcode = barcode {
                barcodeLabel.text = validBarcode
                
                switch validBarcode.count {
                case 8: // EAN-8
                    barcodeImageView.image = RSUnifiedCodeGenerator.shared.generateCode(validBarcode, machineReadableCodeObjectType: AVMetadataObject.ObjectType.ean8.rawValue)
                case 12: // UPC-A
                    barcodeImageView.image = RSUnifiedCodeGenerator.shared.generateCode(validBarcode, machineReadableCodeObjectType: AVMetadataObject.ObjectType.upce.rawValue)
                case 13: // EAN-13
                    barcodeImageView.image = RSUnifiedCodeGenerator.shared.generateCode(validBarcode, machineReadableCodeObjectType: AVMetadataObject.ObjectType.ean13.rawValue)
                default:
                    break
                }
            }
        }
    }

    var mainLanguageCode: String? = nil {
        didSet {
            if let validMainLanguageCode = mainLanguageCode {
                mainLanguageButton?.setTitle(validMainLanguageCode, for: .normal)
            } else {
                mainLanguageButton?.setTitle(TranslatableStrings.QuestionMark, for: .normal)
            }
        }
    }
    
    var editMode = false {
        didSet {
            mainLanguageButton?.isEnabled = editMode
        }
    }
    
    @IBOutlet weak var barcodeImageView: UIImageView!
    
    @IBOutlet weak var barcodeLabel: UILabel!
    
    @IBOutlet weak var mainLanguageButton: UIButton! {
        didSet {
            mainLanguageButton.isEnabled = editMode
        }
    }
    
    @IBAction func mainLanguageTapped(_ sender: UIButton) {    }
}
