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
    
    var nutritionFactsTableStyleSetter: NutritionFactsTableStyleSetter
    var showNutritionFactsTableStyle: NutritionFactsLabelStyle
    var showSaltOrSodium: NatriumChloride
    var showCaloriesOrJoule: EnergyUnitUsed
    var showNutritionDataPerServingOrPerStandard: NutritionDisplayMode
    var mapAddress: Address
    var allowContinuousScan: Bool
    var allergenWarnings: [(String, Bool)] = []
    var favoriteShops: [(String, Address)] = []
    var userDidAuthenticate = false
    var showProductType = ProductType.food {
        didSet {
            if showProductType != oldValue {
                OFFProducts.manager.resetCurrentProductPairs()
            }
        }
    }
    var selectedDiets = ["en:vegan"]
    
    var editMode: Bool = false
    
    init() {
        // The default values are determined by the locale of the user
        // i.e. a user in the US will see the extended list of nutrients, with sodium, in Cal and per serving
        // a user in Europe will see a list of nutrients starting with energy, fat, etc with salt, Joule and per 100 g
        // use standard the style as defined by the current locale
        nutritionFactsTableStyleSetter = .product
        showNutritionFactsTableStyle = .current
        showSaltOrSodium = NutritionFactsLabelStyle.current.saltUnit
        showCaloriesOrJoule = NutritionFactsLabelStyle.current.energyUnit
        switch NutritionFactsLabelStyle.current.entryUnit {
        case .perStandardUnit:
            showNutritionDataPerServingOrPerStandard = .perStandard
        default:
            showNutritionDataPerServingOrPerStandard = .perServing
        }
        allowContinuousScan = false
        
        mapAddress = Address()
        mapAddress.title = "Address used for center of map"
        let locale = Locale.current as NSLocale
        if let validLocale = locale.object(forKey: .countryCode),
            let validCountry = locale.displayName(forKey: .countryCode, value: validLocale) {
            mapAddress.country = validCountry
        }
        mapAddress.setCoordinates()
    }
    
    func cycleProductType() {
        switch showProductType {
        case .food:
            showProductType = .beauty
        case .beauty:
            showProductType = .petFood
        case .petFood:
            showProductType = .product
        case .product:
            showProductType = .food
        }
    }
}
