//
//  AllergenWarningDefaults.swift
//  FoodViewer
//
//  Created by arnaud on 26/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

class AllergenWarningDefaults {
    
    // This class is implemented as a singleton
    // It is only needed by OpenFoodFactRequests.
    // An instance could be loaded for each request
    // A singleton limits however the number of file loads
    static let manager = AllergenWarningDefaults()

    
    var list: [(String, Bool)] = []
    
    private var defaults = NSUserDefaults()
    
    private struct Constants {
        static let AllergenWarningsArrayKey = "Allergen Warnings Array Key"
        static let AllergenKey = "Allergen Key"
        static let WarningKey = "Warning Key"
    }
    
    init() {
        // get the NSUserdefaults array with search strings
        defaults = NSUserDefaults.standardUserDefaults()
        if let allergenDict = defaults.objectForKey(Constants.AllergenWarningsArrayKey) as?
            [[String:AnyObject]] {
            // retrieve the warning array
            for allergen in allergenDict {
                if let allergenKey = allergen[Constants.AllergenKey] as? String,
                    let allergenWarning = allergen[Constants.WarningKey] as? Bool {
                    list.append((allergenKey,allergenWarning))
                }
            }
        } else {
            let allergenKeyArray = OFFplists.manager.OFFallergens?.map(allergenMap)
            // create the allergen warning list
            // the keys include the language "en:" component
            if let validAllergenKeyArray = allergenKeyArray {
                for allergen in validAllergenKeyArray {
                    list.append((allergen, false))
                }
            }
        }
    }
    
    private func allergenMap(s1: VertexNew) -> String { return s1.key }

    
    func updateAllergenWarnings() {
        var newArray: [[String:AnyObject]] = [[:]]
        for (allergen, warning) in list {
            var newDict: [String:AnyObject] = [:]
            newDict[Constants.AllergenKey] = allergen
            newDict[Constants.WarningKey] = warning
            newArray.append(newDict)
        }
        defaults.setObject(newArray, forKey: Constants.AllergenWarningsArrayKey)
        defaults.synchronize()
    }
    
    private func countTrue() -> Int {
        var count = 0
        for (_, value) in list {
            if value {
                count += 1
            }
        }
        return count
    }
    
    func numberOfWarningsSet() -> Int {
        return countTrue()
    }
    
    
    func hasValidWarning(keys: [String]?) -> Bool {
        
        var testKey: String
        
        func keyHasWarning(element: (String, Bool)) -> Bool {
            if (testKey == element.0) && element.1 {
                return true
            }
            return false
        }

        if let validKeys = keys {
            for validKey in validKeys {
                testKey = validKey
                if !list.filter(keyHasWarning).isEmpty {
                    return true
                }
            }
        }
        return false
    }
    
}