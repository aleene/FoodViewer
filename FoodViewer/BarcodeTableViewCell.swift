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
                
                switch validBarcode.length() {
                case 8: // EAN-8
                    barcodeImageView.image = RSUnifiedCodeGenerator.shared.generateCode(validBarcode, machineReadableCodeObjectType: AVMetadataObjectTypeEAN8Code)
                case 12: // UPC-A
                    barcodeImageView.image = RSUnifiedCodeGenerator.shared.generateCode(validBarcode, machineReadableCodeObjectType: AVMetadataObjectTypeUPCECode)

                case 13: // EAN-13
                    barcodeImageView.image = RSUnifiedCodeGenerator.shared.generateCode(validBarcode, machineReadableCodeObjectType: AVMetadataObjectTypeEAN13Code)
                default:
                    break
                }
            }
        }
    }
    
    @IBOutlet weak var barcodeImageView: UIImageView!
    
    @IBOutlet weak var barcodeLabel: UILabel!
}
