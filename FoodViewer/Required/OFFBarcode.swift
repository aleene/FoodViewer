//
//  OFFBarcopde.swift
//  OFFFolksonomy
//
//  Created by aleene 13/10/2022
//

import Foundation

public struct OFFBarcode {

    public var barcode: String {
        didSet {
            if !isCorrect {
                print("OFFBarcode: Barcode length is not UPC, EAN8 or EAN13")
            }
        }
    }
    
    public var isUPC: Bool { barcode.count == 12 }
    
    public var isEAN8: Bool { barcode.count == 8 }

    public var isEAN13: Bool { barcode.count == 13 }

    public var isCorrect: Bool { isEAN8 || isUPC || isEAN13 }

}
