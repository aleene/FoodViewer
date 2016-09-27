//
//  FavoriteShopsDefaults.swift
//  FoodViewer
//
//  Created by arnaud on 26/05/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

class FavoriteShopsDefaults {
    
    // This class is implemented as a singleton
    // It is only needed by OpenFoodFactRequests.
    // An instance could be loaded for each request
    // A singleton limits however the number of file loads
    static let manager = FavoriteShopsDefaults()
    
    
    var list: [(String, Address)] = []
    
    fileprivate var defaults = UserDefaults()
    
    fileprivate struct Constants {
        static let FavoriteShopsArrayKey = "Favorite Shops Array Key"
        static let ShopKey = "Shop Key"
        static let StreetKey = "Street Key"
        static let PostalCodeKey = "Postal Code Key"
        static let CityKey = "City Key"
        static let CountryKey = "Country Key"
    }
    
    init() {
        // let preferredLanguage = Locale.preferredLanguages[0]
        
        // get the NSUserdefaults array with search strings
        defaults = UserDefaults.standard
        if let favoriteShopsDict = defaults.object(forKey: Constants.FavoriteShopsArrayKey) as?
            [[String:AnyObject]] {
            // retrieve the favorite shops array
            for favoriteShop in favoriteShopsDict {
                let shop = favoriteShop[Constants.ShopKey] is String ? favoriteShop[Constants.ShopKey] as! String : ""

                let street =  favoriteShop[Constants.StreetKey] is String ? favoriteShop[Constants.StreetKey] as! String : ""
                let postalcode = favoriteShop[Constants.PostalCodeKey] is String ? favoriteShop[Constants.PostalCodeKey] as! String : ""
                let city = favoriteShop[Constants.CityKey] is String ? favoriteShop[Constants.CityKey] as! String : ""
                let country = favoriteShop[Constants.CountryKey] is String ? favoriteShop[Constants.CountryKey] as! String : ""
                let address = Address.init(newStreet: street,
                                            newPostalcode: postalcode,
                                            newCity: city,
                                            newCountry: country)
                list.append((shop, address))
            }
        }
    }

    
    func updateFavoriteShops() {
        var newArray: [[String:String]] = []
        for (shop, address) in list {
            var newDict: [String:String] = [:]
            newDict[Constants.ShopKey] = shop
            newDict[Constants.StreetKey] = address.street
            newDict[Constants.PostalCodeKey] = address.postalcode
            newDict[Constants.CityKey] = address.city
            newDict[Constants.CountryKey] = address.country
            newArray.append(newDict)
        }
        defaults.set(newArray, forKey: Constants.FavoriteShopsArrayKey)
        defaults.synchronize()
    }

    func addShop(newShop: (String?, Address?)) {
        let shop = newShop.0 != nil ? newShop.0! : ""
        
        let street =  newShop.1?.street != nil ? newShop.1!.street : ""
        let postalcode = newShop.1?.postalcode != nil ? newShop.1!.postalcode : ""
        let city = newShop.1?.city != nil ? newShop.1!.city : ""
        let country = newShop.1?.country != nil ? newShop.1!.country : ""
        let address = Address.init(newStreet: street,
                                   newPostalcode: postalcode,
                                   newCity: city,
                                   newCountry: country)
        list.append((shop, address))
        updateFavoriteShops()
    }
}
