//
//  Address.swift
//  FoodViewer
//
//  Created by arnaud on 24/03/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation
import MapKit

class Address {
    
    internal struct Notification {
        static let CoordinateHasBeenSetForAddressKey = "Address.Notification.CoordinateHasBeenSet.Key"
    }

    var title = ""
    var street = ""
    var city = ""
    var postalcode = ""
    var country = ""    
    var elements: [String] {
        get {
            var array: [String] = []
            if !title.isEmpty {
                array.append(title)
            }
            if !street.isEmpty {
                array.append(street)
            }
            if !postalcode.isEmpty {
                array.append(postalcode)
            }
            if !city.isEmpty {
                array.append(city)
            }
            if !country.isEmpty {
                array.append(country)
            }
            if array.isEmpty {
                return rawArray != nil ? rawArray! : []
            }
            return array
        }
    }
    var locationString: String? = nil {
        didSet {
            if let validLocationString = locationString {
                rawArray = clean(validLocationString.components(separatedBy: ","))
            }
        }
    }
    
    var coordinates: CoordinateFetchResult? = nil {
        didSet {
            if let validCoordinates = coordinates {
                switch validCoordinates {
                case .success:
                    // upon successfull setting ot the variable inform potential users
                    let userInfo = [Notification.CoordinateHasBeenSetForAddressKey:self]
                    NotificationCenter.default.post(name: .CoordinateHasBeenSet, object:nil, userInfo: userInfo)
                default: break
                }
            }
        }
    }
    
    init() {
        self.title = ""
        self.street = ""
        self.city = ""
        self.postalcode = ""
        self.country = ""

    }
    
    init(newStreet: String, newPostalcode: String, newCity: String, newCountry: String) {
        self.street = newStreet
        self.postalcode = newPostalcode
        self.city = newCity
        self.country = newCountry
    }
    
    convenience init(with: (String, Address)?) {
        
        self.init()
        if let shop = with {
            self.title = shop.0
            self.street = shop.1.street
            self.city = shop.1.city
            self.postalcode = shop.1.postalcode
            self.country = shop.1.country
            self.rawArray = [self.title, self.street, self.city, self.postalcode, self.country]
        }
        
    }
    
    var language: String = ""
    var raw: String = ""
    // an array of elements, which should translate to an address if you what is what
    var rawArray: [String]? = nil
    
    enum CoordinateFetchResult {
        case error(String)
        case searchStarted
        case success([CLLocationCoordinate2D])
    }

    
    func getCoordinates() -> CoordinateFetchResult? {
        if coordinates == nil {
            setCoordinates() }
        return coordinates
    }
    
    func setCoordinates() {
        if coordinates == nil {
            // launch the coordinate retrieval
            if !elements.isEmpty {
                rawArray = removeDashes(elements)
                retrieveCoordinates(elements.joined(separator: " "))
            } else if !country.isEmpty {
                if !postalcode.isEmpty {
                    retrieveCoordinates(postalcode + ", " + country)
                } else {
                    retrieveCoordinates(country)
                }
            }
        }
    }
    
    func joined() -> String? {
        return elements.joined(separator: " ")
    }
    
    private func retrieveCoordinates(_ locationName: String) {
        var coordinates: [CLLocationCoordinate2D]? =  nil
        
        if !locationName.isEmpty {
            self.coordinates = .searchStarted
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(locationName) { (placemarks, error) -> Void in
                if error != nil {
                    let error = "Geocode failed with error: \(error!.localizedDescription) for \(locationName)"
                    self.coordinates = CoordinateFetchResult.error(error)
                    print(error)
                } else {
                    coordinates = []
                    if let validPlacemarks = placemarks {
                        for placemark in validPlacemarks {
                            if let validLocation = placemark.location {
                                coordinates!.append(validLocation.coordinate)
                            }
                        }
                        self.coordinates = CoordinateFetchResult.success(coordinates!)
                    }
                }
            }
        }
    }
    
    //  This function returns the street/postalcode/city/country as a single string
    //  It adds delimiters if a field is present
    func asSingleString(withSeparator separator: String) -> String? {
        
        // Create an array with optional String s
        var loc: [String?] = []
        // Fill the array with the address
        loc.append(self.street.count > 0 ? self.street : nil)
        loc.append(self.postalcode.count > 0 ? self.postalcode : nil)
        loc.append(self.city.count > 0 ? self.city : nil)
        loc.append(self.country.count > 0 ? self.country : nil)
        let singleString = loc.compactMap{$0}.joined(separator: separator)
        return singleString.isEmpty ? nil : singleString
    }
    
    //MARK: - Private functions
    
    // This function splits an element in an array in a language and value part
    private func splitLanguageElements(_ inputArray: [String]?) -> [[String: String]]? {
        if let elementsArray = inputArray {
            if !elementsArray.isEmpty {
                var outputArray: [[String:String]] = []
                for element in elementsArray {
                    let elementsPair = element.split(separator:":").map(String.init)
                    let dict = Dictionary(dictionaryLiteral: (elementsPair[0], elementsPair[1]))
                    outputArray.insert(dict, at: 0)
                }
                return outputArray
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    private func removeDashes(_ array: [String]) -> [String] {
        var newArray: [String] = []
        for element in array {
            newArray.append(removeDashes(element))
        }
        return newArray
    }

    private func removeDashes(_ element: String) -> String {
        var newElement = ""
        for character in element {
            if character == "-" {
                newElement.append(" ")
            } else {
                newElement.append(character)
            }
        }
        return newElement
    }
    
    // remove any empty items from a list
    private func clean(_ list: [String]) -> [String] {
        var newList: [String] = []
        if !list.isEmpty {
            for listItem in list {
                if listItem.count > 0 {
                    newList.append(listItem)
                }
            }
        }
        return newList
    }

}

// Definition:
extension Notification.Name {
    static let CoordinateHasBeenSet = Notification.Name("Address.Notification.CoordinateHasBeenSet")
}
