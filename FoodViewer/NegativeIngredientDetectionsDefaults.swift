//
//  NegativeIngredientDetectionsDefaults.swift
//  FoodViewer
//
//  Created by arnaud on 21/07/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import Foundation

class NegativeIngredientDetectionsDefaults {
    
    // This class is implemented as a singleton
    // It is only needed by OpenFoodFactRequests.
    // An instance could be loaded for each request
    // A singleton limits however the number of file loads
    
    static let manager = NegativeIngredientDetectionsDefaults()
    
    var negativeIngredientDetectionsShown: Bool? = nil
    
    fileprivate var defaults = UserDefaults()
    
    fileprivate struct Constants {
        static let NegativeIngredientDetectionsDefaultsKey = "NegativeIngredientDetectionsDefaults.Key"
    }
    
    // initialise the server with the defaults
    init() {
        // get the NSUserdefaults array
        defaults = UserDefaults.standard
        if let server = defaults.object(forKey: Constants.NegativeIngredientDetectionsDefaultsKey) as? Bool {
            negativeIngredientDetectionsShown = server
        } else {
            // no default available, the caller should sort it out
            negativeIngredientDetectionsShown = nil
        }
    }
    
    // this writes the new vontinous scan setting
    func set(_ negativeIngredientDetectionsShown: Bool?) {
        if let valid = negativeIngredientDetectionsShown {
            defaults.set(valid, forKey: Constants.NegativeIngredientDetectionsDefaultsKey)
            defaults.synchronize()
        }
    }
    
}

