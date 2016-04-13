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
    
    struct Notification {
        static let CoordinateSet = "FoodProduct.Notification.CoordinateSet"
        static let CountryCoordinateSet = "FoodProduct.Notification.CountryCoordinateSet"
    }
    
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
        case "Purchase":
            return UIColor.redColor()
        case "Sales Country":
            return UIColor.purpleColor()
        case "Origin Ingredients":
            return UIColor.yellowColor()
        case "Producer":
            return UIColor.blueColor()
        default:
            return UIColor.greenColor()
        }
    }

}
