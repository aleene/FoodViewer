//
//  BarcodeType.swift
//  FoodViewer
//
//  Created by arnaud on 18/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

enum BarcodeType {
    case EAN13(String)
    case EAN8(String)
    case Undefined(String)
    
    init(typeCode: String, value: String) {
        if typeCode == "org.gs1.EAN-13" {
            self = .EAN13(value)
        } else if typeCode == "org.gs1.EAN-8" {
            self = .EAN8(value)
        } else {
            self = .Undefined(value)
        }
    }
    
    init(value: String) {
        self = .Undefined(value)
    }
    
    mutating func string(s: String?) {
        if let newString = s {
            self = .Undefined(newString)
        }
    }
    
    func asString() -> String {
        switch self {
        case .EAN13(let s):
            return s
        case .EAN8(let s):
            return s
        case .Undefined(let s):
            return s
        }
    }
}
