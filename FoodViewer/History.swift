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
    
    fileprivate var defaults = UserDefaults()
    
    fileprivate struct Constants {
        static let HistoryKey = "History Key"
        static let HistorySize = 100
    }

    init() {
        // get the NSUserdefaults array with search strings
        defaults = UserDefaults.standard
        if defaults.object(forKey: Constants.HistoryKey) != nil {
            barcodes = defaults.array(forKey: Constants.HistoryKey) as! [String]
        }

    }
        
    // see also http://stackoverflow.com/questions/30790882/unable-to-append-string-to-array-in-swift/30790932#30790932
    //
    mutating func addBarcode(barcode: String?) {
        if let newBarcode = barcode {
            // is this query new?
            if !barcodes.contains(newBarcode) {
                barcodes.insert(newBarcode, at: 0)
                if barcodes.count > Constants.HistorySize {
                    barcodes.removeLast()
                }
            }
            defaults.set(barcodes, forKey: Constants.HistoryKey)
        }
    }
    
    mutating func deleteQuery(query: String?) {
        if let queryToDelete = query {
            if let deleteIndex = barcodes.index(of: queryToDelete) {
                barcodes.remove(at: deleteIndex)
            }
        }
    }
    
    mutating func removeAll() {
        barcodes.removeAll()
        defaults.set(barcodes, forKey: Constants.HistoryKey)
        defaults.synchronize()
        NotificationCenter.default.post(name: .HistoryHasBeenDeleted, object:nil)
    }
    
}

// Definition:
extension Notification.Name {
    static let HistoryHasBeenDeleted = Notification.Name("History.Notification.HistoryHasBeenDeleted")
}

