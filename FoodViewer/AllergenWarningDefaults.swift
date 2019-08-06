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

    
    var list: [(String, String, Bool)] = []
    
    fileprivate var defaults = UserDefaults()
    
    fileprivate struct Constants {
        static let AllergenWarningsArrayKey = "Allergen Warnings Array Key"
        static let AllergenKey = "Allergen Key"
        static let WarningKey = "Warning Key"
    }
    
    init() {
        let preferredLanguage = Locale.preferredLanguages[0]
        var updateNeeded = false

        // get the NSUserdefaults array with search strings
        defaults = UserDefaults.standard
        if let allergenDict = defaults.object(forKey: Constants.AllergenWarningsArrayKey) as?
            [[String:AnyObject]] {
            // retrieve the warning array
            for allergen in allergenDict {
                if let allergenKey = allergen[Constants.AllergenKey] as? String,
                    let allergenWarning = allergen[Constants.WarningKey] as? Bool {
                    
                    // is there a valid translation found
                    if let translatedKey = OFFplists.manager.translateAllergen(allergenKey, language:preferredLanguage) {
                        list.append((allergenKey, translatedKey, allergenWarning))
                    } else {
                        // the key no longer exists, rquires an update
                        updateNeeded = true
                    }
                }
            }
        } else {
            let allergenKeyArray = OFFplists.manager.OFFallergens?.map(allergenMap)
            // create the allergen warning list
            // the keys include the language "en:" component
            if let validAllergenKeyArray = allergenKeyArray {
                for allergenKey in validAllergenKeyArray {
                    if let translatedKey = OFFplists.manager.translateAllergen(allergenKey, language:preferredLanguage) {
                        list.append((allergenKey, translatedKey, false))
                    }
                }
            }
        }
        if updateNeeded {
            update()
            updateNeeded = false
        }
    }
    
    fileprivate func allergenMap(_ s1: VertexNew) -> String { return s1.key }

    
    func update() {
        var newArray: [[String:AnyObject]] = [[:]]
        for (allergen, _, warning) in list {
            var newDict: [String:AnyObject] = [:]
            newDict[Constants.AllergenKey] = allergen as AnyObject?
            newDict[Constants.WarningKey] = warning as AnyObject?
            newArray.append(newDict)
        }
        defaults.set(newArray, forKey: Constants.AllergenWarningsArrayKey)
        defaults.synchronize()
    }
    
    fileprivate func countTrue() -> Int {
        var count = 0
        for (_, _, value) in list {
            if value {
                count += 1
            }
        }
        return count
    }
    
    func numberOfWarningsSet() -> Int {
        return countTrue()
    }
    
    
    func hasValidWarning(_ keys: [String]?) -> Bool {
        
        var testKey: String
        
        func keyHasWarning(_ element: (String, String, Bool)) -> Bool {
            if (testKey == element.0) && element.2 {
                return true
            }
            return false
        }

        if let validKeys = keys {
            if validKeys.isEmpty {
                return false
            }
            
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
