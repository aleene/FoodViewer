//
//  BarcodeType.swift
//  FoodViewer
//
//  Created by arnaud on 18/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

enum BarcodeType {
    case ean13(String)
    case ean8(String)
    case undefined(String)
    
    init(typeCode: String, value: String) {
        if typeCode == "org.gs1.EAN-13" {
            self = .ean13(value)
        } else if typeCode == "org.gs1.EAN-8" {
            self = .ean8(value)
        } else {
            self = .undefined(value)
        }
    }
    
    init(value: String) {
        self = .undefined(value)
    }
    
    mutating func string(_ s: String?) {
        if let newString = s {
            self = .undefined(newString)
        }
    }
    
    func asString() -> String {
        switch self {
        case .ean13(let s):
            return s
        case .ean8(let s):
            return s
        case .undefined(let s):
            return s
        }
    }
}
