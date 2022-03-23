//
//  Route.swift
//  AppCyciingRoute
//
//  Created by Ivan Bolotin on 03.02.2022.
//

import Foundation
import MapKit

class Route {
    
    /* var vc = ViewController()
    class func createDirectionRequest(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D, completion: @escaping (Double?) ->()) {
        let startLocation = MKPlacemark(coordinate: startCoordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        //var timeRoute: Double?
        
        let direction = MKDirections(request: request)
        direction.calculate { response, error in
            if let error = error { return }
            if let route = response?.routes[0] {
                let timeRoute = route.expectedTravelTime/180
                //vc.mapView.addOverlay(route.polyline)
                completion(timeRoute)
            }
            
            
        }
    }*/
}
