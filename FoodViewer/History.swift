//
//  History.swift
//  FoodViewer
//
//  Created by arnaud on 28/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

public struct History {

    public var barcodes = [String]()
    
    private var defaults = NSUserDefaults()
    
    private struct Constants {
        static let HistoryKey = "History Key"
        static let HistorySize = 100
    }

    init() {
        // get the NSUserdefaults array with search strings
        defaults = NSUserDefaults.standardUserDefaults()
        if defaults.objectForKey(Constants.HistoryKey) != nil {
            barcodes = defaults.arrayForKey(Constants.HistoryKey) as! [String]
        }

    }
        
    // see also http://stackoverflow.com/questions/30790882/unable-to-append-string-to-array-in-swift/30790932#30790932
    //
    mutating func addBarcode(barcode barcode: String?) {
        if let newBarcode = barcode {
            // is this query new?
            if !barcodes.contains(newBarcode) {
                barcodes.insert(newBarcode, atIndex: 0)
                if barcodes.count > Constants.HistorySize {
                    barcodes.removeLast()
                }
            }
            defaults.setObject(barcodes, forKey: Constants.HistoryKey)
        }
    }
    
    mutating func deleteQuery(query query: String?) {
        if let queryToDelete = query {
            if let deleteIndex = barcodes.indexOf(queryToDelete) {
                barcodes.removeAtIndex(deleteIndex)
            }
        }
    }
    
    mutating func removeAll() {
        barcodes.removeAll()
        defaults.setObject(barcodes, forKey: Constants.HistoryKey)
        defaults.synchronize()
    }
    
}