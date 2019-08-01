//
//  ViewToggleModeDefaults.swift
//  FoodViewer
//
//  Created by arnaud on 21/07/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import Foundation

class ViewToggleModeDefaults {
    
    // This class is implemented as a singleton
    // It is only needed by OpenFoodFactRequests.
    // An instance could be loaded for each request
    // A singleton limits however the number of file loads
    
    static let manager = ViewToggleModeDefaults()
    
    var buttonNotDoubleTap: Bool? = nil
    
    var buttonNotDoubleTapDefault = true
    
    fileprivate var defaults = UserDefaults()
    
    fileprivate struct Constants {
        static let ViewToggleModeDefaultsKey = "ViewToggleModeDefaults.Key"
    }
    
    // initialise the server with the defaults
    init() {
        // get the NSUserdefaults array
        defaults = UserDefaults.standard
        if let server = defaults.object(forKey: Constants.ViewToggleModeDefaultsKey) as? Bool {
            buttonNotDoubleTap = server
        } else {
            // no default available, the caller should sort it out
            buttonNotDoubleTap = nil
        }
    }
    
    // this writes the new vontinous scan setting
    func set(_ viewToggleModeIsButtonNotDoubleTap: Bool?) {
        if let valid = viewToggleModeIsButtonNotDoubleTap {
            defaults.set(valid, forKey: Constants.ViewToggleModeDefaultsKey)
            defaults.synchronize()
            self.buttonNotDoubleTapDefault = valid
        }
    }
    
}

