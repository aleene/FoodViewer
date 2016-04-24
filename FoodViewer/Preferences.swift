//
//  Preferences.swift
//  
//
//  Created by arnaud on 12/04/16.
//
//

import Foundation

class Preferences {
    
    // This class is implemented as a singleton
    // The Preferences are now used by the SettingsVC and the NutritionsTableVC
    // Unfortunately moving to another VC deletes the products, so it must be stored somewhere more permanently.
    // A singleton limits however the number of file loads
    
    static let manager = Preferences()
    
    var showSaltOrSodium: NatriumChloride
    var showCaloriesOrJoule: Energy
    var mapAddress: Address
    
    init() {
        showSaltOrSodium = NatriumChloride.Salt
        showCaloriesOrJoule = Energy.Joule
        mapAddress = Address()
        mapAddress.title = "Address used for center of map"
        let locale = NSLocale.currentLocale()
        mapAddress.country = locale.displayNameForKey(NSLocaleCountryCode, value: locale.objectForKey(NSLocaleCountryCode)!)!
        mapAddress.setCoordinates()
    }
}