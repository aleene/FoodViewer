//
//  ContinuousScanDefaults.swift
//  FoodViewer
//
//  Created by arnaud on 27/02/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import Foundation

class ContinuousScanDefaults {
    
    // This class is implemented as a singleton
    // It is only needed by OpenFoodFactRequests.
    // An instance could be loaded for each request
    // A singleton limits however the number of file loads
    
    static let manager = ContinuousScanDefaults()
    
    
    var allowContinuousScan: Bool? = nil
    
    fileprivate var defaults = UserDefaults()
    
    fileprivate struct Constants {
        static let ContinuousScanKey = "ContinuousScan.Key"
    }
    
    // initialise the server with the defaults
    init() {
        
        // get the NSUserdefaults array 
        defaults = UserDefaults.standard
        if let server = defaults.object(forKey: Constants.ContinuousScanKey) as? Bool {
            allowContinuousScan = server
        } else {
            // not default available, the caller should sort it out
            allowContinuousScan = nil
        }
    }
    
    // this writes the new vontinous scan setting 
    func set(_ continuousScan: Bool?) {
        if let valid = continuousScan {
            defaults.set(valid, forKey: Constants.ContinuousScanKey)
            defaults.synchronize()
        }
    }
    
}

