//
//  BarcodeType.swift
//  FoodViewer
//
//  Created by arnaud on 18/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

enum BarcodeType {
    case ean13(String, ProductType)
    case ean8(String, ProductType)
    case undefined(String, ProductType)
    
    init(typeCode: String, value: String) {
        let defaultProductType: ProductType = .food
        if typeCode == "org.gs1.EAN-13" {
            self = .ean13(value, defaultProductType)
        } else if typeCode == "org.gs1.EAN-8" {
            self = .ean8(value, defaultProductType)
        } else {
            self = .undefined(value, defaultProductType)
        }
    }
    
    init(typeCode: String, value: String, type: ProductType) {
        if typeCode == "org.gs1.EAN-13" {
            self = .ean13(value, type)
        } else if typeCode == "org.gs1.EAN-8" {
            self = .ean8(value, type)
        } else {
            self = .undefined(value, type)
        }
    }

    init(value: String) {
        self = .undefined(value, .food)
    }
    
    init(barcodeTuple: (String, String)) {
        if let productType = ProductType.contains(barcodeTuple.1) {
            self = .undefined(barcodeTuple.0, productType)
        } else {
            self = .undefined(barcodeTuple.0, .food)
        }
    }
    
    mutating func string(_ s: String?) {
        if let newString = s {
            self = .undefined(newString, .food)
        }
    }
    
    func asString() -> String {
        switch self {
        case .ean13(let s, _):
            return s
        case .ean8(let s, _):
            return s
        case .undefined(let s, _):
            return s
        }
    }
    
    func productType() -> ProductType {
        switch self {
        case .ean13(_, let s):
            return s
        case .ean8(_, let s):
            return s
        case .undefined(_, let s):
            return s
        }
    }
}
