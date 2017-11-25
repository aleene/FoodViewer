//
//  BarcodeScanViewController.swift
//  FoodViewer
//
//  Created by arnaud on 14/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import AVFoundation

class BarcodeScanViewController: RSCodeReaderViewController {
        
    var barcode: String = ""
    var type: String = ""
    var dispatched: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.focusMarkLayer.strokeColor = UIColor.red.cgColor
        
        self.cornersLayer.strokeColor = UIColor.yellow.cgColor
                
        self.tapHandler = { point in
            print(point)
        }
        
        // MARK: NOTE: If you want to detect specific barcode types, you should update the types
        var types = self.output.availableMetadataObjectTypes
        // MARK: NOTE: Uncomment the following line remove QRCode scanning capability
        types = types.filter({ $0 != AVMetadataObject.ObjectType.qr })
        types = types.filter({ $0 != AVMetadataObject.ObjectType.pdf417 })
        types = types.filter({ $0 != AVMetadataObject.ObjectType.aztec })
        types = types.filter({ $0 != AVMetadataObject.ObjectType.dataMatrix })
        self.output.metadataObjectTypes = types
        
        // MARK: NOTE: If you layout views in storyboard, you should these 3 lines
        for subview in self.view.subviews {
            self.view.bringSubview(toFront: subview)
        }
        
        self.barcodesHandler = { barcodes in
            if !self.dispatched { // triggers for only once
                self.dispatched = true
                for barcode in barcodes {
                    self.barcode = barcode.stringValue!
                    self.type = barcode.type.rawValue
                    // print("Barcode found: type=" + barcode.type + " value=" + barcode.stringValue)
                    
                    DispatchQueue.main.async(execute: {
                        self.performSegue(withIdentifier: "Unwind New Search", sender: self)
                        
                        // MARK: NOTE: Perform UI related actions here.
                    })
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.dispatched = false // reset the flag so user can do another scan
        
        super.viewWillAppear(animated)
        
        // self.navigationController?.navigationBarHidden = true
        
    }
}
