//
//  BarcodeScanViewController.swift
//  FoodViewer
//
//  Created by arnaud on 14/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import RSBarcodes_Swift
import AVFoundation

class BarcodeScanViewController: RSCodeReaderViewController {
        
    var barcode: String = ""
    var type: String = ""
    var dispatched: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.focusMarkLayer.strokeColor = UIColor.redColor().CGColor
        
        self.cornersLayer.strokeColor = UIColor.yellowColor().CGColor
                
        self.tapHandler = { point in
            print(point)
        }
        
        
        let types = NSMutableArray(array: self.output.availableMetadataObjectTypes)
        types.removeObject(AVMetadataObjectTypeQRCode)
        types.removeObject(AVMetadataObjectTypePDF417Code)
        types.removeObject(AVMetadataObjectTypeAztecCode)
        types.removeObject(AVMetadataObjectTypeDataMatrixCode)

        self.output.metadataObjectTypes = NSArray(array: types) as [AnyObject]
        
        // MARK: NOTE: If you layout views in storyboard, you should these 3 lines
        for subview in self.view.subviews {
            self.view.bringSubviewToFront(subview)
        }
        
        self.barcodesHandler = { barcodes in
            if !self.dispatched { // triggers for only once
                self.dispatched = true
                for barcode in barcodes {
                    self.barcode = barcode.stringValue
                    self.type = barcode.type
                    print("Barcode found: type=" + barcode.type + " value=" + barcode.stringValue)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.performSegueWithIdentifier("Unwind New Search", sender: self)
                        
                        // MARK: NOTE: Perform UI related actions here.
                    })
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.dispatched = false // reset the flag so user can do another scan
        
        super.viewWillAppear(animated)
        
        // self.navigationController?.navigationBarHidden = true
        
    }
}
