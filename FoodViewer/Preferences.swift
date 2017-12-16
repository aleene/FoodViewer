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
    
//    public struct Notification {
//        static let ShowProductTypeSetKey = "Preferences.Notification.ShowProductTypeSe.Key"
//    }

    static let manager = Preferences()
    
    
    var showSaltOrSodium: NatriumChloride
    var showCaloriesOrJoule: EnergyUnitUsed
    var showNutritionDataPerServingOrPerStandard: NutritionDisplayMode
    var mapAddress: Address
    var allergenWarnings: [(String, Bool)] = []
    var favoriteShops: [(String, Address)] = []
    var userDidAuthenticate = false
    var showProductType = ProductType.food {
        didSet {
            if showProductType != oldValue {
                OFFProducts.manager.resetCurrentProducts()
            }
        }
    }
    
    init() {
        showSaltOrSodium = .salt
        showCaloriesOrJoule = .joule
        showNutritionDataPerServingOrPerStandard = .perStandard
        
        mapAddress = Address()
        mapAddress.title = "Address used for center of map"
        let locale = Locale.current
        mapAddress.country = (locale as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: (locale as NSLocale).object(forKey: NSLocale.Key.countryCode)!)!
        mapAddress.setCoordinates()
    }
    
    func cycleProductType() {
        switch showProductType {
        case .food:
            showProductType = .beauty
        case .beauty:
            showProductType = .petFood
        case .petFood:
            showProductType = .food
        }
    }
}
