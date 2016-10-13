//
//  SupplyChainLocation.swift
//  FoodViewer
//
//  Created by arnaud on 22/03/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation
import MapKit

class SupplyChainLocation: NSObject, MKAnnotation {
    
    
    let title: String?
    let discipline: String
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0.0, 0.0)
    var subtitle: String? {
        return discipline
    }
    
    var locationName: String
    
    init(title: String, locationName: String, discipline: String) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
    }
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
    }

    // pinColor for supply chain location type: Ingredient Origin, Production Location, Sales Locations, Buy location, other
    func pinColor() -> UIColor  {
        switch discipline {
        case MapPinCategories.PurchaseLocation:
            return UIColor.red
        case MapPinCategories.SalesCountryLocation:
            return UIColor.purple
        case MapPinCategories.IngredientOriginLocation:
            return UIColor.yellow
        case MapPinCategories.ProducerLocation:
            return UIColor.blue
        case MapPinCategories.ProducerCodes:
            return UIColor.cyan
        default:
            return UIColor.green
        }
    }

}

// Definition:
extension Notification.Name {
    static let CoordinateSet = Notification.Name("FoodProduct.Notification.CoordinateSet")
    static let CountryCoordinateSet = Notification.Name("FoodProduct.Notification.CountryCoordinateSet")
}

