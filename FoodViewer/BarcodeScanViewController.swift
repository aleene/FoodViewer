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
        
    private var barcode: String = ""
    var type: String = ""
    var dispatched: Bool = false
    
    fileprivate var products = OFFProducts.manager
    
    fileprivate var barcodeType = BarcodeType(barcodeString: TranslatableStrings.EnterBarcode, type: Preferences.manager.showProductType) {
        didSet {
            // get the index of the existing productPair
            if let validSection = products.indexOfProductPair(with: barcodeType) {
                OFFProducts.manager.selectedProduct = validSection
            } else {
                // create a new productPair
                let validSection = products.createProduct(with: barcodeType)
                OFFProducts.manager.selectedProduct = validSection
            }
        }
    }
    
    private func switchToTab(with index: Int) {
        if let tabVC = self.parent as? UITabBarController {
            tabVC.selectedIndex = index
        } else {
            assert(true, "BarcodeScanViewController:switchToTab:with: TabBar hierarchy error")
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        if let tabVC = self.parent as? UITabBarController {
            // start out with the scanner tab
            tabVC.selectedIndex = 0
            tabVC.delegate = self
        }

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
                    print("Barcode found: type= " +  self.type + " value=" + self.barcode)
                    // create this barcode in the history
                    self.barcodeType = BarcodeType(typeCode:self.type, value:self.barcode, type:Preferences.manager.showProductType)
                    DispatchQueue.main.async(execute: {
                        // I should move to the history tab and open the product found
                        self.switchToTab(with: 1)
                        //self.performSegue(withIdentifier: "Unwind New Search", sender: self)
                        
                    })
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.dispatched = false // reset the flag so user can do another scan
        
        super.viewWillAppear(animated)
        
    }
}

// MARK: - UITabBarControllerDelegate Functions

extension BarcodeScanViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {

    }
    
}
