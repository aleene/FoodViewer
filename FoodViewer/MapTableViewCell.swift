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
                    return CLLocation.init(latitude: coordinateValues[0].latitude, longitude: coordinateValues[0].longitude)
                case .error, .searchStarted:
                    return CLLocation.init(latitude: 0.0, longitude: 0.0)
                }

            } else {
                return CLLocation.init(latitude: 0.0, longitude: 0.0)
            }
        }
    }
    
    fileprivate let regionRadius: CLLocationDistance = 1000000

    var product: FoodProduct? = nil {
        didSet {
            if let currentProduct = product {
                if let coordinates = currentProduct.purchaseLocation?.getCoordinates() {
                    switch coordinates {
                    case .success(let coordinateValues):
                        let annotation = SupplyChainLocation(title: product!.purchaseLocation!.joined()!, locationName: product!.purchaseLocation!.joined()!, discipline: MapPinCategories.PurchaseLocation, coordinate: coordinateValues[0])
                        mapView.addAnnotation(annotation)
                    default:
                        break
                    }
                }
                
                if let coordinates = currentProduct.producer?.getCoordinates() {
                    switch coordinates {
                    case .success(let coordinateValues):
                        let annotation = SupplyChainLocation(title: product!.producer!.joined()!, locationName: product!.producer!.joined()!, discipline: MapPinCategories.ProducerLocation, coordinate: coordinateValues[0])
                        mapView.addAnnotation(annotation)
                    default:
                        break
                    }
                }
                
                if let coordinates = currentProduct.ingredientsOrigin?.getCoordinates() {
                    switch coordinates {
                    case .success(let coordinateValues):
                        let annotation = SupplyChainLocation(title: product!.ingredientsOrigin!.joined()!, locationName: product!.ingredientsOrigin!.joined()!, discipline: MapPinCategories.IngredientOriginLocation, coordinate: coordinateValues[0])
                        mapView.addAnnotation(annotation)
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

                
                if let countries = currentProduct.countries {
                    for country in countries {
                        if let coordinates = country.getCoordinates() {
                            switch coordinates {
                            case .success(let coordinateValues):
                                if !coordinateValues.isEmpty {
                                    let annotation = SupplyChainLocation(title: country.country, locationName: country.country, discipline: MapPinCategories.SalesCountryLocation, coordinate: coordinateValues[0])
                                    mapView.addAnnotation(annotation)
                                }
                            default:
                                break
                            }
                        }
                    }
                }
            }
            mapView.delegate = self

            zoomMapViewToFitAnnotations(mapView, animated:true)
        }
    }
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            centerMapOnLocation(initialLocation)
            mapView.delegate = self
        }
    }
    
    func centerMapOnLocation(_ location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
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
    func zoomMapViewToFitAnnotations(_ mapView: MKMapView, animated: Bool)
    {
        struct MapkitConstants {
            static let MINIMUM_ZOOM_ARC = CLLocationDegrees(5)  // (1 degree of arc ~= 110 km)
            static let ANNOTATION_REGION_PAD_FACTOR = 1.3
            static let MAX_DEGREES_ARC = CLLocationDegrees(360)
            static let MaxDegreesLatitude = CLLocationDegrees(180)
        }

        if mapView.annotations.count == 0 { return } //bail if no annotations
    
        var center = CLLocationCoordinate2D()
        let (min, max) = minMax(mapView.annotations)
        
        let span = MKCoordinateSpan(latitudeDelta: max.latitude - min.latitude, longitudeDelta: max.longitude - min.longitude)
        center.latitude = (max.latitude - min.latitude) / 2 + min.latitude
        center.longitude = (max.longitude - min.longitude) / 2 + min.longitude
        
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
    
    func minMax(_ array: [MKAnnotation]) -> (CLLocationCoordinate2D, CLLocationCoordinate2D) {
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
 
