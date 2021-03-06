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

    /// this is the  barcode structure, each barcode also contains the product type
    /// .0 - barcode
    /// .1 - barcodeType
    /// .2 - comment
    public var barcodeTuples: [(String,String, String?)] = []
    
    private var debug = false
    
    private var defaults = UserDefaults()
    
    private struct Constants {
        struct Key {
            static let History = "History Key" // This is only needed for  upgrade
            static let NewHistory = "HistoryKey"
            static let BarcodeNumber = "BarcodeNumberKey"
            static let BarcodeType = "BarcodeTypeKey"
            static let Comment = "Key.Comment"
        }
        static let HistorySize = 50
    }
    
    private var historyKey: String {
        get {
            return Constants.Key.NewHistory
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
        defaults.set(barcodeTuples, forKey: Constants.Key.History)

        if let barcodeDict = defaults.array(forKey: historyKey) as? [[String:AnyObject]] {
            for dict in barcodeDict {
                let barcodeNumber = dict[Constants.Key.BarcodeNumber] as? String ?? ""
                let barcodeType = dict[Constants.Key.BarcodeType] as? String ?? ""
                let comment = dict[Constants.Key.Comment] as? String
                barcodeTuples.append((barcodeNumber, barcodeType, comment))
            }
        // read the old structure
        } else if let barcodes = defaults.array(forKey: Constants.Key.History) as? [String] {
            for barcode in barcodes {
                self.barcodeTuples.append((barcode, ProductType.food.rawValue, nil))
            }
            update()
            // use the new structure
        }
    }
        
    // see also http://stackoverflow.com/questions/30790882/unable-to-append-string-to-array-in-swift/30790932#30790932
    //
    mutating func add(barcodeType: BarcodeType, with comment: String?
    ) {
        var newBarcodeTuple: (String, String, String?) = ("", "", nil)
        newBarcodeTuple.0 = barcodeType.asString
        // default to a food product
        newBarcodeTuple.1 = barcodeType.productType?.rawValue ?? ProductType.food.rawValue
        newBarcodeTuple.2 = comment
        // is this barcode new?
        if let index = barcodeIndex(barcodeType.asString) {
            barcodeTuples[index] = newBarcodeTuple
        } else {
            barcodeTuples.insert(newBarcodeTuple, at: 0)
            while barcodeTuples.count > Constants.HistorySize {
                barcodeTuples.removeLast()
            }
        }
        // rewrite the entire history file
        update()
    }
    
    mutating func remove(_ barcodetype: BarcodeType) {
        if let validIndex = index(for: barcodetype) {
            barcodeTuples.remove(at: validIndex)
            update()
        }
    }
    
    private func barcodeExists(_ barcodeNumber: String) -> Bool {
        return barcodeIndex(barcodeNumber) != nil ? true : false
    }
    
    private func barcodeIndex(_ barcodeNumber: String) -> Int? {
        for (index, barcodeTuple) in barcodeTuples.enumerated() {
            if barcodeTuple.0 == barcodeNumber {
                return index
            }
        }
        return nil
    }

    func info(for type: ProductType) -> [(String, String?)] {
        var list: [(String, String?)] = []
        for index in 0..<barcodeTuples.count {
            // only append the products for the current product type
            if barcodeTuples[index].1 == type.rawValue {
                list.append((barcodeTuples[index].0, barcodeTuples[index].2))
            }
        }
        return list
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
        return index(barcode.asString)
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
            dict[Constants.Key.BarcodeNumber] = barcodeTuple.0
            dict[Constants.Key.BarcodeType] = barcodeTuple.1
            dict[Constants.Key.Comment] = barcodeTuple.2
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

