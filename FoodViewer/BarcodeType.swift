//
//  BarcodeType.swift
//  FoodViewer
//
//  Created by arnaud on 18/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

enum BarcodeType {
    case ean13(String, ProductType?)
    case ean8(String, ProductType?)
    case upc12(String, ProductType?)
    case sample(String, ProductType?)
    case search(SearchTemplate, ProductType?)
    case undefined(String, ProductType?)
    case notSet
    case mostRecent(String, ProductType?)
    
    init(typeCode: String, value: String) {
        if typeCode == "org.gs1.EAN-13" {
            self = .ean13(value, nil)
        } else if typeCode == "org.gs1.EAN-8" {
            self = .ean8(value, nil)
        } else {
            self = .undefined(value, nil)
        }
    }
    
    init(typeCode: String, value: String, type: ProductType?) {
        if typeCode == "org.gs1.EAN-13" {
            self = .ean13(value, type)
        } else if typeCode == "org.gs1.EAN-8" {
            self = .ean8(value, type)
        } else {
            self = .undefined(value, type)
        }
    }

    //init(value: String) {
    //    self = .undefined(value, .food)
    //}
    
    init(barcodeString: String, type: ProductType) {
        self = .undefined(barcodeString, type)
    }
    
    mutating func string(_ s: String?) {
        if let newString = s {
            switch self {
            case .sample:
                self = .sample(newString, nil)
            case .ean13:
                self = .ean13(newString, nil)
            case .ean8:
                self = .ean8(newString, nil)
            case .upc12:
                self = .upc12(newString, nil)
            case .undefined:
                self = .undefined(newString, nil)
            default:
                self = .undefined("tried to set a search", nil)
            }
        }
    }
    
    var asString: String {
        switch self {
        case .ean13(let s, _):
            return s
        case .sample(let s, _):
            return s
        case .ean8(let s, _):
            return s
        case .upc12(let s, _):
            return s
        case .undefined(let s, _):
            return s
        case .mostRecent(let s, _):
            return s
        default:
            return "not relevant"
        }
    }
    
    var fill: String {
        switch self {
        case .ean13(var s, _):
            let len = s.count + 1
            for _ in len...13 {
                s += "x"
            }
            return s
        case .ean8(var s, _):
            let len = s.count + 1
            for _ in len...8 {
                s += "x"
            }
            return s
        case .upc12(var s, _):
            let len = s.count + 1
            for _ in len...12 {
                s += "x"
            }
            return s
        case .undefined(let s, _):
            return s
        default:
            return "not relevant"
        }
    }

    
    var productType: ProductType? {
        switch self {
        case .ean13(_, let s):
            return s
        case .sample(_, let s):
            return s
        case .ean8(_, let s):
            return s
        case .upc12(_, let s):
            return s
        case .undefined(_, let s):
            return s
        case .search(_, let s):
            return s
        default:
            return nil
        }
    }
    
    mutating func setType(_ type:ProductType?) {
        switch self {
        case .sample(let code, _):
            self = .sample(code, type)

        case .ean13(let code, _):
            self = .ean13(code, type)
        case .ean8(let code, _):
            self = .ean8(code, type)
        case .upc12(let code, _):
            self = .upc12(code, type)
        case .undefined(let code, _):
            self = .undefined(code, type)
        case .search(let code, _):
            self = .search(code, type)
        default:
            break
        }
        
    }
    
    var isSearch: Bool {
        switch self {
        case .search:
            return true
        default:
            return false
        }
    }
    
    var isSet: Bool {
        switch self {
        case .notSet:
            return false
        default:
            return true
        }
    }


}
