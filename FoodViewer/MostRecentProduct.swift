//
//  MostRecentProduct.swift
//  FoodViewer
//
//  Created by arnaud on 18/04/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

public struct MostRecentProduct {
    
    public var jsonData: Data? = nil
    
    fileprivate var defaults = UserDefaults()
    
    fileprivate struct Constants {
        static let MostRecentProductKey = "Most Recent Product Key"
    }
    
    init() {
        // get the NSUserdefaults array with search strings
        defaults = UserDefaults.standard
        if defaults.object(forKey: Constants.MostRecentProductKey) != nil {
            if let data = defaults.data(forKey: Constants.MostRecentProductKey) {
                jsonData = data
            }
        }
    }
    
    mutating func addMostRecentProduct(_ data: Data?) {
        if let newData = data {
            defaults.set(newData, forKey: Constants.MostRecentProductKey)
            defaults.synchronize()
        }
    }
    
    mutating func remove() {
        let removedData = Data()
        defaults.set(removedData, forKey: Constants.MostRecentProductKey)
        defaults.synchronize()
    }
    
}
