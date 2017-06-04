//
//  MostRecentProduct.swift
//  FoodViewer
//
//  Created by arnaud on 18/04/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//
//  This class stores the most recent product data in the userDefaults.
//

import Foundation

public struct MostRecentProduct {
    
    // This calculated variable returns the jsonData for the current product type if it has been stored
    public var jsonData: Data? {
        return storedJsonData[currentProductType] ?? nil
    }
    
    
    
    private var currentProductType: String {
        return Preferences.manager.showProductType.rawValue
    }
        
    private var storedJsonData: [String:Data] = [:]
    
    private var defaults = UserDefaults()
    
    private struct Key {
        static let MostRecentProduct = "FVMostRecentProductKey"
        static let MostRecentProductType = "FVMostRecentProductTypeKey"
        static let MostRecentProductData = "FVMostRecentProductDataKey"
    }
    
    // Read all the data (jsons) stored as userDefaults
    init() {
        defaults = UserDefaults.standard
        
        // The json data is stored as an array of dictionaries
        if let mostRecentProductsDict = defaults.array(forKey: Key.MostRecentProduct) as? [[String:Any]] {
            for dict in mostRecentProductsDict {
                let productType = dict[Key.MostRecentProductType] is String ? dict[Key.MostRecentProductType] as! String : ""
                let jsonData = dict[Key.MostRecentProductData] is Data ? dict[Key.MostRecentProductData] as! Data : Data()
                if productType.length() > 0 && jsonData.count > 0 {
                    storedJsonData[productType] = jsonData
                }
            }
        }
    }
    
    // The data (json) for the current product type will be added
    mutating func addMostRecentProduct(_ data: Data?) {
        
        if let newData = data {
            storedJsonData[currentProductType] = newData
            
            rewrite()
        }
    }
    
    // The data (jsons) for ALL product types will be removed
    mutating func removeAll() {
        let removedData: [[String:Any]] = []
        defaults.set(removedData, forKey: Key.MostRecentProduct)
        defaults.synchronize()
    }
    
    // The data (jsons) for the current product type will be removed
    mutating func removeForCurrentProductType() {
        storedJsonData[currentProductType] = Data()
        rewrite()
    }

    private func rewrite() {
        var newArray: [[String:Any]] = []
        // save the barcodes in the new structure
        for (key, value) in storedJsonData {
            var dict: [String:Any] = [:]
            dict[Key.MostRecentProductType] = key as String
            dict[Key.MostRecentProductData] = value as Data
            newArray.append(dict)
        }
        defaults.set(newArray, forKey: Key.MostRecentProduct)
        defaults.synchronize()
    }
    
}
