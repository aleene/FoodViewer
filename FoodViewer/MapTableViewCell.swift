 //
//  MapTableViewCell.swift
//  FoodViewer
//
//  Created by arnaud on 22/03/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import UIKit
import MapKit

class MapTableViewCell: UITableViewCell, MKMapViewDelegate {
    
    struct MapConstants {
        static let PurchaseLocation = "Purchase"
        static let ProducerLocation = "Producer"
        static let SalesCountryLocation = "Sales Country"
        static let IngredientOriginLocation = "Origin Ingredients"
        static let SpaceDelimiter = " "
    }

    private let initialLocation = CLLocation(latitude: 0.0, longitude: 0.0)
    private let regionRadius: CLLocationDistance = 1000000

    var product: FoodProduct? = nil {
        didSet {
            if let currentProduct = product {
                if let coordinates = currentProduct.purchaseLocation?.coordinate {
                    let annotation = SupplyChainLocation(title: product!.purchaseLocation!.joined()!, locationName: product!.purchaseLocation!.joined()!, discipline: MapConstants.PurchaseLocation, coordinate: coordinates[0])
                    mapView.addAnnotation(annotation)
                }
                
                if let coordinates = currentProduct.producer?.coordinate {
                    let annotation = SupplyChainLocation(title: product!.producer!.joined()!, locationName: product!.producer!.joined()!, discipline: MapConstants.ProducerLocation, coordinate: coordinates[0])
                    mapView.addAnnotation(annotation)
                }
                
                if let coordinates = currentProduct.ingredientsOrigin?.coordinate {
                    let annotation = SupplyChainLocation(title: product!.ingredientsOrigin!.joined()!, locationName: product!.ingredientsOrigin!.joined()!, discipline: MapConstants.IngredientOriginLocation, coordinate: coordinates[0])
                    mapView.addAnnotation(annotation)
                }
                
                if let countries = currentProduct.countries {
                    for country in countries {
                        if let coordinates = country.coordinate {
                            if !coordinates.isEmpty {
                                let annotation = SupplyChainLocation(title: country.country, locationName: country.country, discipline: MapConstants.SalesCountryLocation, coordinate: coordinates[0])
                                mapView.addAnnotation(annotation)
                                // centerMapOnLocation(CLLocation(latitude: coordinates[0].latitude, longitude: coordinates[0].longitude))
                            }
                        }
                    }
                }
            }
            mapView.delegate = self
            zoomMapViewToFitAnnotations(self.mapView, animated:true);
        }
    }
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            centerMapOnLocation(initialLocation)
            mapView.delegate = self
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? SupplyChainLocation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.pinTintColor = annotation.pinColor()
                view.detailCalloutAccessoryView?.backgroundColor = UIColor.whiteColor()
                // view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
    
    //size the mapView region to fit its annotations
    func zoomMapViewToFitAnnotations(mapView: MKMapView, animated: Bool)
    {
        struct MapkitConstants {
            static let MINIMUM_ZOOM_ARC = CLLocationDegrees(5)  //approximately 1 miles (1 degree of arc ~= 69 miles)
            static let ANNOTATION_REGION_PAD_FACTOR = 1.15
            static let MAX_DEGREES_ARC = CLLocationDegrees(360)
            static let MaxDegreesLatitude = CLLocationDegrees(180)
        }

        if mapView.annotations.count == 0 { return } //bail if no annotations
    
        var center = CLLocationCoordinate2D()
        let (min, max) = minMax(mapView.annotations)
        
        let span = MKCoordinateSpan(latitudeDelta: max.latitude - min.latitude, longitudeDelta: max.longitude - min.longitude)
        center.latitude = (max.latitude - min.latitude) / 2 + min.latitude
        center.longitude = (max.longitude - min.longitude) / 2 + min.longitude
        
        //create MKMapRect from array of MKMapPoint
        // let mapRect = MKMapRect( ) // [[MKPolygon polygonWithPoints:points count:count] boundingMapRect];MKMapRect
        //convert MKCoordinateRegion from MKMapRect
        var region = MKCoordinateRegion(center: center, span: span)
    
        //add padding so pins aren't scrunched on the edges
        region.span.latitudeDelta  *= MapkitConstants.ANNOTATION_REGION_PAD_FACTOR
        region.span.longitudeDelta *= MapkitConstants.ANNOTATION_REGION_PAD_FACTOR
        //but padding can't be bigger than the world
        if( region.span.latitudeDelta > MapkitConstants.MaxDegreesLatitude) {
            region.span.latitudeDelta  = MapkitConstants.MaxDegreesLatitude
        }
        if( region.span.longitudeDelta > MapkitConstants.MAX_DEGREES_ARC) {
            region.span.longitudeDelta = MapkitConstants.MAX_DEGREES_ARC
        }
    
        //and don't zoom in stupid-close on small samples
        if( region.span.latitudeDelta  < MapkitConstants.MINIMUM_ZOOM_ARC ) {
            region.span.latitudeDelta  = MapkitConstants.MINIMUM_ZOOM_ARC
        }
        if( region.span.longitudeDelta < MapkitConstants.MINIMUM_ZOOM_ARC ) {
            region.span.longitudeDelta = MapkitConstants.MINIMUM_ZOOM_ARC
        }
        //and if there is a sample of 1 we want the max zoom-in instead of max zoom-out
        if( mapView.annotations.count == 1 )
        {
            region.span.latitudeDelta = MapkitConstants.MINIMUM_ZOOM_ARC
            region.span.longitudeDelta = MapkitConstants.MINIMUM_ZOOM_ARC
        }
        mapView.setRegion(region, animated: true)
    }
    
    func minMax(array: [MKAnnotation]) -> (CLLocationCoordinate2D, CLLocationCoordinate2D) {
        var currentLongitudeMin = array[0].coordinate.longitude
        var currentLongitudeMax = array[0].coordinate.longitude
        var currentLatitudeMin = array[0].coordinate.latitude
        var currentLatitudeMax = array[0].coordinate.latitude
        for value in array[1..<array.count] {
            if value.coordinate.latitude < currentLatitudeMin {
                currentLatitudeMin = value.coordinate.latitude
            } else if value.coordinate.latitude > currentLatitudeMax {
                currentLatitudeMax = value.coordinate.latitude
            }
            if value.coordinate.longitude < currentLongitudeMin {
                currentLongitudeMin = value.coordinate.longitude
            } else if value.coordinate.longitude > currentLongitudeMax {
                currentLongitudeMax = value.coordinate.longitude
            }
        }
        return (CLLocationCoordinate2D(latitude: currentLatitudeMin, longitude: currentLongitudeMin),
            CLLocationCoordinate2D(latitude: currentLatitudeMax, longitude: currentLongitudeMax))
    }

 }
 


