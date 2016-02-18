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
    case Undefined(String)
    
    mutating func string(s: String?) {
        if let newString = s {
            self = .Undefined(newString)
        }
    }
    
    func asString() -> String {
        switch self {
        case .EAN13(let s):
            return s
        case .Undefined(let s):
            return s
        }
    }
}
