//
//  JSON.swift
//  FoodViewer
//
//  Created by arnaud on 03/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

// json parse approach taken from
//
// http://www.atimi.com/simple-json-parsing-swift-2/
//

public enum JSON {
    case Array([AnyObject])
    case Dictionary([Swift.String: AnyObject])
    case String(Swift.String)
    case Number(Float)
    case URL(Swift.String)
    case Null
    
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
        case .Number(let d):
            return Int(d)
        default:
            return nil
        }
    }
    
    public var float: Float? {
        switch self {
        case .Number(let d):
            return d
        default:
            return nil
        }
    }

    public var double: Double? {
        switch self {
        case .Number(let d):
            return Double(d)
        default:
            return nil
        }
    }

    public var bool: Bool? {
        switch self {
        case .Number(let d):
            return (d != 0)
        default:
            return nil
        }
    }
    
    public var nsurl: NSURL? {
        switch self {
        case .String(let u):
            let url = NSURL(string: u)
            return url
        default:
            return nil
        }
    }

    public var date: NSDate? {
        switch self {
        case .String(let d):
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            dateFormatter.locale = NSLocale(localeIdentifier: "EN_en")
            return dateFormatter.dateFromString(d)
        default:
            return nil
        }
    }

    public var time: NSDate? {
        switch self {
        case .Number(let d):
            return NSDate(timeIntervalSince1970:Double(d))
        default:
            return nil
        }
    }

    public var isNull: Bool {
        switch self {
        case Null:
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
    
    public var stringArray: [Swift.String]? {
        switch self {
        case .Array(let array):
            if let stringArray = array as? [Swift.String] {
                return stringArray
            }
            fallthrough
        default:
            return nil
        }
    }


    public static func wrap(json: AnyObject) -> JSON {
        if let str = json as? Swift.String {
            return .String(str)
        }
        if let num = json as? NSNumber {
            return .Number(num.floatValue)
        }
        if let dictionary = json as? [Swift.String: AnyObject] {
            return .Dictionary(dictionary)
        }
        if let array = json as? [AnyObject] {
            return .Array(array)
        }
        assert(json is NSNull, "Unsupported Type")
        return .Null
    }
    
    public static func parse(data: NSData) -> JSON? {
        do {
            let jsonObject: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
            return wrap(jsonObject)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
    
    public subscript(index: Swift.String) -> JSON? {
        switch self {
        case .Dictionary(let dictionary):
            if let value: AnyObject = dictionary[index] {
                return JSON.wrap(value)
            }
            fallthrough
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
