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
        static let CoordinateHasBeenSet = "Address.Notification.CoordinateHasBeenSet"
        static let CoordinateHasBeenSetForAddressKey = "Address.Notification.CoordinateHasBeenSet.Key"
    }

    var title = ""
    var street = ""
    var city = ""
    var postalcode = ""
    var country = ""    
    var elements: [String]? = nil
    var locationString: String? = nil {
        didSet {
            if let validLocationString = locationString {
                elements = validLocationString.components(separatedBy: ",")
            }
        }
    }
        /*
 {
        didSet {
            if (elements != nil) && (!elements!.isEmpty) {
                elements = removeDashes(elements!)
                // retrieveCoordinates(elements!.joinWithSeparator(" "))
            }
        }
    }
 */
    var language: String = ""
    var raw: String = ""
    
    enum CoordinateFetchResult {
        case error(String)
        case searchStarted
        case success([CLLocationCoordinate2D])
    }

    var coordinates: CoordinateFetchResult? = nil {
        didSet {
            if let validCoordinates = coordinates {
                switch validCoordinates {
                case .success:
                    let userInfo = [Notification.CoordinateHasBeenSetForAddressKey:self]
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: Notification.CoordinateHasBeenSet), object:nil, userInfo: userInfo)
                default: break
                }
            }
        }
    }
    
    func getCoordinates() -> CoordinateFetchResult? {
        setCoordinates()
        return coordinates
    }
    
    func setCoordinates() {
        if coordinates == nil {
            // launch the image retrieval
            if (elements != nil) && (!elements!.isEmpty) {
                elements = removeDashes(elements!)
                retrieveCoordinates(elements!.joined(separator: " "))
            } else if !country.isEmpty {
                if !postalcode.isEmpty {
                    retrieveCoordinates(postalcode + ", " + country)
                } else {
                    retrieveCoordinates(country)
                }
            }
        }
    }
    

    
    /*
    var languageCountry = "" {
        didSet {
            if !languageCountry.isEmpty {
                let countryDictArray = splitLanguageElements([languageCountry])
                let countryDict = countryDictArray!.first
                (language, country) = countryDict!.first!
                retrieveCoordinates(country)
            }

        }
    }
 */
    
    func joined() -> String? {
        return elements?.joined(separator: " ")
    }
    
    func retrieveCoordinates(_ locationName: String) {
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
    
    // This function splits an element in an array in a language and value part
    func splitLanguageElements(_ inputArray: [String]?) -> [[String: String]]? {
        if let elementsArray = inputArray {
            if !elementsArray.isEmpty {
                var outputArray: [[String:String]] = []
                for element in elementsArray {
                    let elementsPair = element.characters.split{$0 == ":"}.map(String.init)
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
    func removeDashes(_ array: [String]) -> [String] {
        var newArray: [String] = []
        for element in array {
            newArray.append(removeDashes(element))
        }
        return newArray
    }

    func removeDashes(_ element: String) -> String {
        var newElement = ""
        for character in element.characters {
            if character == "-" {
                newElement.append(" ")
            } else {
                newElement.append(character)
            }
        }
        return newElement
    }
}
