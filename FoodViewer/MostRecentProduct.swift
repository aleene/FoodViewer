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

public class MostRecentProduct {
    
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
                if productType.count > 0 && jsonData.count > 0 {
                    storedJsonData[productType] = jsonData
                }
            }
        }
    }
    
    func save(_ barcode: BarcodeType?) {
        if let validBarcode = barcode {
            let request = OpenFoodFactsRequest()
            // loading the product from internet will be done off the main queue
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
                let fetchResult = request.fetchJsonForBarcode(validBarcode)
                DispatchQueue.main.async(execute: { () -> Void in
                    switch fetchResult {
                    case .success(let data):
                        // This will store the data in the user defaults file
                        self.storedJsonData[self.currentProductType] = data
                        self.rewrite()
                    default:
                        break
                    }
                })
            })
        }
    }

    // The data (json) for the current product type will be added
    func addMostRecentProduct(_ data: Data?) {
        
        if let newData = data {
            storedJsonData[currentProductType] = newData
            
            rewrite()
        }
    }
    
    // The data (jsons) for ALL product types will be removed
    func removeAll() {
        let removedData: [[String:Any]] = []
        defaults.set(removedData, forKey: Key.MostRecentProduct)
        defaults.synchronize()
    }
    
    // The data (jsons) for the current product type will be removed
    func removeForCurrentProductType() {
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
    
    func load(completionHandler: @escaping (FoodProduct?) -> ()) {
        // load the most recent product from the local storage
        if let data = jsonData {
            var fetchResult = ProductFetchStatus.loading("most recent")
            fetchResult = OpenFoodFactsRequest().fetchStoredProduct(data)
            switch fetchResult {
            case .success(let product):
                completionHandler(product)
                return
            default:
                break
            }
        }
        completionHandler(nil)
        return
    }
    
}
