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
    var showNutritionDataPerServingOrPerStandard: NutritionDisplayMode
    var mapAddress: Address
    var allergenWarnings: [(String, Bool)] = []
    var favoriteShops: [(String, Address)] = []
    var userDidAuthenticate: Bool = false
    
    init() {
        showSaltOrSodium = NatriumChloride.salt
        showCaloriesOrJoule = Energy.joule
        showNutritionDataPerServingOrPerStandard = NutritionDisplayMode.perStandard
        
        mapAddress = Address()
        mapAddress.title = "Address used for center of map"
        let locale = Locale.current
        mapAddress.country = (locale as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: (locale as NSLocale).object(forKey: NSLocale.Key.countryCode)!)!
        mapAddress.setCoordinates()
    }
}
