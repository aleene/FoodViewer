//
//  LastServerDefaults.swift
//  FoodViewer
//
//  Created by arnaud on 08/05/17.
//  Copyright © 2017 Hovering Above. All rights reserved.
//

import Foundation

class LastServerDefaults {
    
    // This class is implemented as a singleton
    // It is only needed by OpenFoodFactRequests.
    // An instance could be loaded for each request
    // A singleton limits however the number of file loads
    static let manager = LastServerDefaults()
    
    
    var productType: ProductType? = nil
    
    fileprivate var defaults = UserDefaults()
    
    fileprivate struct Constants {
        static let LastServerKey = "LastServerKey"
    }
    
    // initialise the server with the defaults
    init() {
        
        // get the NSUserdefaults array with search string
        defaults = UserDefaults.standard
        if let server = defaults.object(forKey: Constants.LastServerKey) as? String {
            productType = ProductType.contains(server)
        } else {
            // not default available
            productType = nil
        }
    }
    
    // this writes the new server string
    func set(_ productType: ProductType?) {
        if let server = productType?.rawValue {
            defaults.set(server, forKey: Constants.LastServerKey)
            defaults.synchronize()
            self.productType = productType
        }
    }
    
}

