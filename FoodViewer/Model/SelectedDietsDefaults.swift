//
//  SelectedDietsDefaults.swift
//  FoodViewer
//
//  Created by arnaud on 04/09/2019.
//  Copyright © 2019 Hovering Above. All rights reserved.
//

import Foundation


class SelectedDietsDefaults {
    
    // This class is implemented as a singleton
    // It is only needed by OpenFoodFactRequests.
    // An instance could be loaded for each request
    // A singleton limits however the number of file loads
    
    static let manager = SelectedDietsDefaults()
    
    fileprivate var defaults = UserDefaults()
    
    fileprivate struct Constants {
        static let SelectedDietsKey = "SelectedDiets.Key"
    }
    
    // This variable contains the keys (as found in the plist) of diets
    // preferred by the user.
    var selected: [String] = []
    
    // initialise the server with the defaults
    init() {
        // get the NSUserdefaults array
        defaults = UserDefaults.standard
        if let sel = defaults.object(forKey: Constants.SelectedDietsKey) as? [String] {
            selected = sel
        } else {
            // no default available, add a list of demo diets
            selected = Preferences.manager.selectedDiets
        }
    }
    
    // add a new key to the selected diets if necessary
    func addDiet(with key: String) {
        if key.count >= 2,
            !selected.contains(key) {
            selected.append(key)
            defaults.set(selected, forKey: Constants.SelectedDietsKey)
            defaults.synchronize()
        }
    }
    
    // add a new key to the selected diets if necessary
    func removeDiet(with key: String) {
        if key.count >= 2,
            let index = selected.firstIndex(of: key) {
            selected.remove(at: index)
            defaults.set(selected, forKey: Constants.SelectedDietsKey)
            defaults.synchronize()
        }
    }

    
}

