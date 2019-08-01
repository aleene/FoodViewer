//
//  TagEntryLanguageDefaults.swift
//  FoodViewer
//
//  Created by arnaud on 21/07/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import Foundation

class TagEntryLanguageDefaults {
    
    // This class is implemented as a singleton
    // It is only needed by OpenFoodFactRequests.
    // An instance could be loaded for each request
    // A singleton limits however the number of file loads
    
    static let manager = TagEntryLanguageDefaults()
    
    var productLanguageNotSystemLanguage: Bool? = nil
    
    fileprivate var defaults = UserDefaults()
    
    fileprivate struct Constants {
        static let TagEntryLanguageDefaultsKey = "TagEntryLanguageDefaults.Key"
    }
    
    // initialise the server with the defaults
    init() {
        // get the NSUserdefaults array
        defaults = UserDefaults.standard
        if let server = defaults.object(forKey: Constants.TagEntryLanguageDefaultsKey) as? Bool {
            productLanguageNotSystemLanguage = server
        } else {
            // no default available, the caller should sort it out
            productLanguageNotSystemLanguage = nil
        }
    }
    
    // this writes the new vontinous scan setting
    func set(_ tagEntryLanguageProductNotSystem: Bool?) {
        if let valid = tagEntryLanguageProductNotSystem {
            defaults.set(valid, forKey: Constants.TagEntryLanguageDefaultsKey)
            defaults.synchronize()
            self.productLanguageNotSystemLanguage = valid
        }
    }
    
}

