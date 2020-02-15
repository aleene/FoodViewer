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
    

    fileprivate var initialLocation: CLLocation {
        get {
            if let coordinates = Preferences.manager.mapAddress.coordinates {
                switch coordinates {
                case .success(let coordinateValues):
                    return CLLocation.init(latitude: coordinateValues.first!.latitude, longitude: coordinateValues[0].longitude)
                case .error, .searchStarted:
                    break
                }
            }
            return CLLocation.init(latitude: 0.0, longitude: 0.0)
        }
    }
    
    private var annotations: [MKAnnotation] = []
    
    // fileprivate let regionRadius: CLLocationDistance = 1000000

    var product: FoodProduct? = nil {
        didSet {
            // if there are any annotations on the map remove them
            // note that this is set multiple times
            mapView.removeAnnotations(mapView.annotations)
            
            if let currentProduct = product {
                if let coordinates = currentProduct.purchasePlacesAddress?.getCoordinates() {
                    switch coordinates {
                    case .success(let coordinateValues):
                        let annotation = SupplyChainLocation(title: product!.purchasePlacesAddress!.joined()!, locationName: product!.purchasePlacesAddress!.joined()!, discipline: MapPinCategories.PurchaseLocation, coordinate: coordinateValues[0])
                        annotations.append(annotation)
                    default:
                        break
                    }
                }
                
                if let coordinates = currentProduct.manufacturingPlacesAddress?.getCoordinates() {
                    switch coordinates {
                    case .success(let coordinateValues):
                        let annotation = SupplyChainLocation(title: product!.manufacturingPlacesAddress!.joined()!, locationName: product!.manufacturingPlacesAddress!.joined()!, discipline: MapPinCategories.ProducerLocation, coordinate: coordinateValues[0])
                        annotations.append(annotation)
                    default:
                        break
                    }
                }
                
                if let coordinates = currentProduct.originsAddress?.getCoordinates() {
                    switch coordinates {
                    case .success(let coordinateValues):
                        let annotation = SupplyChainLocation(title: product!.originsAddress!.joined()!, locationName: product!.originsAddress!.joined()!, discipline: MapPinCategories.IngredientOriginLocation, coordinate: coordinateValues[0])
                        annotations.append(annotation)
                    default:
                        break
                    }
                }
                
                // The Apple forward geocoding API, does not work with postalcodes, so no location van be retrieved.
/*
                if let codes = currentProduct.producerCode {
                    for code in codes {
                        if let coordinates = code.getCoordinates() {
                            switch coordinates {
                            case .Success(let coordinateValues):
                                if !coordinateValues.isEmpty {
                                    let annotation = SupplyChainLocation(title: code.raw, locationName: code.postalcode + " " + code.country, discipline: MapPinCategories.ProducerCodes, coordinate: coordinateValues[0])
                                    mapView.addAnnotation(annotation)
                                }
                            default:
                                break
                            }
                        }
                    }
                }
*/

                if !currentProduct.countriesAddress.isEmpty {
                    for country in currentProduct.countriesAddress {
                        if let coordinates = country.getCoordinates() {
                            switch coordinates {
                            case .success(let coordinateValues):
                                if !coordinateValues.isEmpty {
                                    let annotation = SupplyChainLocation(title: country.country, locationName: country.country, discipline: MapPinCategories.SalesCountryLocation, coordinate: coordinateValues[0])
                                    annotations.append(annotation)
                                }
                            default:
                                break
                            }
                        }
                    }
                }
            }
            mapView.delegate = self
            mapView.addAnnotations(annotations)
            // mapView.showAnnotations(mapView.annotations, animated: true)
            zoomMapViewToFitAnnotations(mapView, animated:true)
            // print("S: \(mapView.region.span.latitudeDelta), \(mapView.region.span.longitudeDelta)")
            // print("Frame: \(mapView.frame.size.height), \(mapView.frame.size.width)")

        }
    }
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            centerMapOnLocation(initialLocation)
            mapView.delegate = self
            mapView.frame.size = CGSize(width:240, height:320)
            // mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }
    
    private func centerMapOnLocation(_ location: CLLocation) {
        zoomMapViewToFitAnnotations(mapView, animated:true)

        // let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        // mapView.setRegion(coordinateRegion, animated: true)
    }

    internal func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? SupplyChainLocation {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView { // 2
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                // view.calloutOffset = CGPoint(x: -5, y: 5)
                view.pinTintColor = annotation.pinColor()
                // view.detailCalloutAccessoryView = UIView(frame: CGRectMake(0.0,0.0,200.0,50.0))
                // view.detailCalloutAccessoryView!.backgroundColor = UIColor.redColor()
                // view.detailCalloutAccessoryView!.intrinsicContentSize()
                // view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
    
    //size the mapView region to fit its annotations
    private func zoomMapViewToFitAnnotations(_ mapView: MKMapView, animated: Bool)
    {
        struct MapkitConstants {
            static let SPAN_MINIMUM_DELTA_DEGREES = CLLocationDegrees(8)  // (1 degree of arc ~= 110 km)
            static let ANNOTATION_REGION_PAD_FACTOR = 1.2
            static let SPAN_MAX_LONGITUDE_DEGREES = CLLocationDegrees(360)
            static let SPAN_MAX_LATITUDE_DEGREES = CLLocationDegrees(180)
        }

        guard mapView.annotations.count > 0 else { return } //bail if no annotations

        var center = CLLocationCoordinate2D()
        let (min, max) = minMax(mapView.annotations)
        var span = MKCoordinateSpan(latitudeDelta: max.longitude - min.longitude, longitudeDelta: max.longitude - min.longitude)
        if (max.latitude - min.latitude) > (max.longitude - min.longitude) {
            span = MKCoordinateSpan(latitudeDelta: max.latitude - min.latitude, longitudeDelta: max.latitude - min.latitude)
        }
        center.latitude = (max.latitude - min.latitude) / 2 + min.latitude
        center.longitude = (max.longitude - min.longitude) / 2 + min.longitude
        
        var region = MKCoordinateRegion(center: center, span: span)
    
        //add padding so pins aren't scrunched on the edges
        region.span.latitudeDelta  *= MapkitConstants.ANNOTATION_REGION_PAD_FACTOR
        region.span.longitudeDelta *= MapkitConstants.ANNOTATION_REGION_PAD_FACTOR
        
        //but padded region can't be bigger than the world, just show the whole world
        if( region.span.latitudeDelta > MapkitConstants.SPAN_MAX_LATITUDE_DEGREES) {
            region.span.latitudeDelta  = MapkitConstants.SPAN_MAX_LATITUDE_DEGREES
            region.span.longitudeDelta = MapkitConstants.SPAN_MAX_LONGITUDE_DEGREES
        }
        if( region.span.longitudeDelta > MapkitConstants.SPAN_MAX_LONGITUDE_DEGREES) {
            region.span.latitudeDelta  = MapkitConstants.SPAN_MAX_LATITUDE_DEGREES
            region.span.longitudeDelta = MapkitConstants.SPAN_MAX_LONGITUDE_DEGREES
        }
    
        //and don't zoom in stupid-close on small samples
        if( region.span.latitudeDelta  < MapkitConstants.SPAN_MINIMUM_DELTA_DEGREES ) {
            region.span.latitudeDelta  = MapkitConstants.SPAN_MINIMUM_DELTA_DEGREES
        }
        if( region.span.longitudeDelta < MapkitConstants.SPAN_MINIMUM_DELTA_DEGREES ) {
            region.span.longitudeDelta = MapkitConstants.SPAN_MINIMUM_DELTA_DEGREES
        }
        //and if there is a sample of 1 we want the max zoom-in instead of max zoom-out
        if( mapView.annotations.count == 1 ) {
            region.span.latitudeDelta = MapkitConstants.SPAN_MINIMUM_DELTA_DEGREES
            region.span.longitudeDelta = MapkitConstants.SPAN_MINIMUM_DELTA_DEGREES
        }
        // print("Ci: \(region.center.longitude), \(region.center.latitude)")
        
        // print("Si: \(region.span.latitudeDelta), \(region.span.longitudeDelta)")

        mapView.setRegion(region, animated: false)
        // print("C: \(mapView.region.center.longitude), \(mapView.region.center.latitude)")

        // print("S: \(mapView.region.span.latitudeDelta), \(mapView.region.span.longitudeDelta)")
        
    }
    
    private func minMax(_ array: [MKAnnotation]) -> (CLLocationCoordinate2D, CLLocationCoordinate2D) {
        var currentLongitudeMinDegrees = array[0].coordinate.longitude
        var currentLongitudeMaxDegrees = array[0].coordinate.longitude
        var currentLatitudeMinDegrees = array[0].coordinate.latitude
        var currentLatitudeMaxDegrees = array[0].coordinate.latitude
        // print("Coord0: \(currentLatitudeMinDegrees), \(currentLongitudeMinDegrees)")

        for value in array[1..<array.count] {
            if value.coordinate.latitude < currentLatitudeMinDegrees {
                currentLatitudeMinDegrees = value.coordinate.latitude
            }
            if value.coordinate.latitude > currentLatitudeMaxDegrees {
                currentLatitudeMaxDegrees = value.coordinate.latitude
            }
            if value.coordinate.longitude < currentLongitudeMinDegrees {
                currentLongitudeMinDegrees = value.coordinate.longitude
            }
            if value.coordinate.longitude > currentLongitudeMaxDegrees {
                currentLongitudeMaxDegrees = value.coordinate.longitude
            }
            // print("Coord: \(value.coordinate.latitude), \(value.coordinate.longitude)")
        }
        // print("Min:\(currentLatitudeMinDegrees), \(currentLongitudeMinDegrees)")
        // print("Max:\(currentLatitudeMaxDegrees), \(currentLongitudeMaxDegrees)")
        return (CLLocationCoordinate2D(latitude: currentLatitudeMinDegrees, longitude: currentLongitudeMinDegrees),
            CLLocationCoordinate2D(latitude: currentLatitudeMaxDegrees, longitude: currentLongitudeMaxDegrees))
    }

 }
 
