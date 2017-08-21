//
//  History.swift
//  FoodViewer
//
//  Created by arnaud on 28/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//
//  This class manages the history of the products that the user viewed.
//  This history is written to the standard user defaults
//  There is a single HistoryKey for ALL product types. The product type is stored with the barcode.

import Foundation

public struct History {

    // this is the old barcode structure set to private as we no longer need it
    // private var barcodes = [String]()
    // this is the new barcode structure, each barcode also contains the product type
    public var barcodeTuples: [(String,String)] = []
    
    private var debug = false
    
    private var defaults = UserDefaults()
    
    private struct Constants {
        static let HistoryKey = "History Key" // This is only needed for  upgrade
        static let NewHistoryKey = "HistoryKey"
        // static let FoodHistoryKey = "FoodHistoryKey"
        // static let PetFoodHistoryKey = "PetFoodHistoryKey"
        // static let BeautyHistoryKey = "BeautyHistoryKey"
        static let BarcodeNumberKey = "BarcodeNumberKey"
        static let BarcodeTypeKey = "BarcodeTypeKey"
        static let HistorySize = 50
    }
    
    private var historyKey: String {
        get {
            return Constants.NewHistoryKey
            /*
            switch Preferences.manager.useOpenFactsServer {
            case .food:
                return Constants.FoodHistoryKey
            case .petFood:
                return Constants.PetFoodHistoryKey
            case .beauty:
                return Constants.BeautyHistoryKey
            }
            */
        }
    }

    init() {
        // get the NSUserdefaults array with search strings
        defaults = UserDefaults.standard
//        if debug {
//            for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
//                print("\(key) = \(value) \n")
//            }
//        }
        
        // get rid of old stuff
        barcodeTuples.removeAll()
        defaults.set(barcodeTuples, forKey: Constants.HistoryKey)

        if let barcodeDict = defaults.array(forKey: historyKey) as? [[String:AnyObject]] {
            for dict in barcodeDict {
                let barcodeNumber = dict[Constants.BarcodeNumberKey] is String ? dict[Constants.BarcodeNumberKey] as! String : ""
                let barcodeType = dict[Constants.BarcodeTypeKey] is String ? dict[Constants.BarcodeTypeKey] as! String : ""
                barcodeTuples.append((barcodeNumber,barcodeType))
            }
        } else if let barcodes = defaults.array(forKey: Constants.HistoryKey) as? [String] {
            for barcode in barcodes {
                self.barcodeTuples.append((barcode, ProductType.food.rawValue))
            }
            update()
            // use the new structure
        }
    }
        
    // see also http://stackoverflow.com/questions/30790882/unable-to-append-string-to-array-in-swift/30790932#30790932
    //
    mutating func add(_ barcodeTuple: (String, String?)?) {
        if let newBarcode = barcodeTuple {
            // is this barcode new?
            if !barcodeExists(newBarcode.0) {
                var newBarcodeTuple: (String,String) = ("", "")
                newBarcodeTuple.0 = newBarcode.0
                // default to a food product
                newBarcodeTuple.1 = newBarcode.1 ?? ProductType.food.rawValue
                barcodeTuples.insert(newBarcodeTuple, at: 0)
                while barcodeTuples.count > Constants.HistorySize {
                    barcodeTuples.removeLast()
                }
            }
            // rewrite the entire history file
            update()
        }
    }
    
    private func barcodeExists(_ barcodeNumber: String) -> Bool {
        for barcodeTuple in barcodeTuples {
            if barcodeTuple.0 == barcodeNumber {
                return true
            }
        }
        return false
    }
    
    private func index(_ barcodeNumber: String?) -> Int? {
        for (index, barcodeTuple) in barcodeTuples.enumerated() {
            if barcodeTuple.0 == barcodeNumber {
                return index
            }
        }
        return nil
    }
    
    func index(for barcode:BarcodeType) -> Int? {
        return index(barcode.asString())
    }
    
    mutating func deleteQuery(_ query: String?) {
        if let queryToDelete = query {
            if let deleteIndex = index(queryToDelete) {
                barcodeTuples.remove(at: deleteIndex)
            }
        }
    }
    
    mutating func removeAll() {
        barcodeTuples.removeAll()
        defaults.set(barcodeTuples, forKey: historyKey)
        defaults.synchronize()
        NotificationCenter.default.post(name: .HistoryHasBeenDeleted, object:nil)
    }
    
    private func update() {
        var newArray: [[String:String]] = []
        // save the barcodes in the new structure
        for barcodeTuple in self.barcodeTuples {
            var dict: [String:String] = [:]
            dict[Constants.BarcodeNumberKey] = barcodeTuple.0
            dict[Constants.BarcodeTypeKey] = barcodeTuple.1
            newArray.append(dict)
        }
        defaults.set(newArray, forKey: historyKey)
        defaults.synchronize()
    }
}

// Definition:
extension Notification.Name {
    static let HistoryHasBeenDeleted = Notification.Name("History.Notification.HistoryHasBeenDeleted")
}

