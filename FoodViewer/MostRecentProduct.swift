//
//  MostRecentProduct.swift
//  FoodViewer
//
//  Created by arnaud on 18/04/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

public struct MostRecentProduct {
    
    public var jsonData: NSData? = nil
    
    private var defaults = NSUserDefaults()
    
    private struct Constants {
        static let MostRecentProductKey = "Most Recent Product Key"
    }
    
    init() {
        // get the NSUserdefaults array with search strings
        defaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey(Constants.MostRecentProductKey) != nil {
            if let data = defaults.dataForKey(Constants.MostRecentProductKey) {
                jsonData = data
            }
        }
    }
    
    mutating func addMostRecentProduct(data: NSData?) {
        if let newData = data {
            defaults.setObject(newData, forKey: Constants.MostRecentProductKey)
            defaults.synchronize()
        }
    }
    
    mutating func remove() {
        let removedData = NSData()
        defaults.setObject(removedData, forKey: Constants.MostRecentProductKey)
        defaults.synchronize()
    }
    
}