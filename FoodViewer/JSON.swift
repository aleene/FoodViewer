//
//  JSON.swift
//  FoodViewer
//
//  Created by arnaud on 03/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//
/*
import Foundation

// json parse approach taken from
//
// http://www.atimi.com/simple-json-parsing-swift-2/
//

public enum JSON {
    case Array([Any])
    case Dictionary([Swift.String: Any])
    case String(Swift.String)
    case number(Float)
    case url(Swift.String)
    case null
    
    public var string: Swift.String? {
        switch self {
        case .String(let s):
            return s
        default:
            return nil
        }
    }
    
    public var int: Int? {
        switch self {
        case .number(let d):
            return Int(d)
        default:
            return nil
        }
    }
    
    public var float: Float? {
        switch self {
        case .number(let d):
            return d
        default:
            return nil
        }
    }

    public var double: Double? {
        switch self {
        case .number(let d):
            return Double(d)
        default:
            return nil
        }
    }

    public var bool: Bool? {
        switch self {
        case .number(let d):
            return (d != 0)
        default:
            return nil
        }
    }
    
    public var nsurl: Foundation.URL? {
        switch self {
        case .String(let u):
            let url = Foundation.URL(string: u)
            return url
        default:
            return nil
        }
    }

    public var date: Date? {
        switch self {
        case .String(let d):
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            dateFormatter.locale = Locale(identifier: "EN_en")
            return dateFormatter.date(from: d)
        default:
            return nil
        }
    }

    public var time: Date? {
        switch self {
        case .number(let d):
            return Date(timeIntervalSince1970:Double(d))
        default:
            return nil
        }
    }

    public var isNull: Bool {
        switch self {
        case .null:
            return true
        default:
            return false
        }
    }
    
    public var dictionary: [Swift.String: JSON]? {
        switch self {
        case .Dictionary(let d):
            var jsonObject: [Swift.String: JSON] = [:]
            for (k,v) in d {
                jsonObject[k] = JSON.wrap(v)
            }
            return jsonObject
        default:
            return nil
        }
    }
    
    public var array: [JSON]? {
        switch self {
        case .Array(let array):
            let jsonArray = array.map({ JSON.wrap($0) })
            return jsonArray
        default:
            return nil
        }
    }
    
    public var stringArray: [String]? {
        switch self {
        case .Array(let array):
            if let stringArray = array as? [String] {
                return stringArray
            }
            fallthrough
        default:
            return nil
        }
    }


    public static func wrap(_ json: Any) -> JSON {
        if let str = json as? String {
            return .String(str)
        }
        if let num = json as? NSNumber {
            return .number(num.floatValue)
        }
        if let dictionary = json as? [String: Any] {
            return .Dictionary(dictionary)
        }
        if let array = json as? [Any] {
            return .Array(array)
        }
        assert(json is NSNull, "Unsupported Type")
        return .null
    }
    
    public static func parse(_ data: Data) -> JSON? {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
            
            return wrap(jsonObject)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
    
    public subscript(index: Swift.String) -> JSON? {
        switch self {
        case .Dictionary(let dictionary):
            return JSON.wrap(dictionary[index] as Any)
        default:
            return nil
        }
    }
    
    public subscript(index: Int) -> JSON? {
        switch self {
        case .Array(let array):
            return JSON.wrap(array[index])
        default:
            return nil
        }
    }
}
*/
