//
//  Route.swift
//  AppCyciingRoute
//
//  Created by Ivan Bolotin on 03.02.2022.
//

import Foundation
import MapKit

class Route {
    
    /*var vc = ViewController()
    
    var places: [Places] = []
    
    func startAddress(addressPlace: String) {
        var sP: Places!
        if (addressPlace == "Моё местоположение") {
            sP = Places(
                title: "Точка старта",
                locationName: "\(addressPlace)",
                discipline: "Я",
                coordinate: vc.startCoordinates)
            self.places.insert(sP, at: 0)
            vc.mapView.addAnnotations(self.places)
            
            // Добавление начальной точки при загрузке карты
            let initialLocation = CLLocation(latitude: vc.startCoordinates.latitude, longitude: vc.startCoordinates.longitude)
            vc.mapView.centerLocation(initialLocation)
            
            /*for i in 0...self.places.count-1 {
                print(self.places[i].title)
            }*/
            
        } else {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(addressPlace) { [self] placemarks, error in
                guard let placemarks = placemarks else { return}
                let placemark = placemarks.first
                guard let placemarkLocation = placemark?.location else { return }
                sP = Places(
                    title: "Точка старта",
                    locationName: "\(addressPlace)",
                    discipline: "Я",
                    coordinate: placemarkLocation.coordinate)
                self.places.insert(sP, at: 0)
                vc.mapView.addAnnotations(self.places)
                
                // Добавление начальной точки при загрузке карты
                let initialLocation = CLLocation(latitude: placemarkLocation.coordinate.latitude, longitude: placemarkLocation.coordinate.longitude)
                vc.mapView.centerLocation(initialLocation)
               
                /*for i in 0...self.places.count-1 {
                    print(self.places[i].title)
                }*/
            }
        }
    }
    
    func loadInitialData() {
        var fileName = String()
        switch vc.city {
        case "Смоленск":
            fileName = "PlacesSmolensk"
        case "Москва":
            fileName = "PlacesMoscow"
        case "Санкт-Петербург":
            fileName = "PlacesStPeterburg"
        case "Париж":
            fileName = "PlacesParis"
        case "Казань":
            fileName = "PlacesKazan"
        case "Тест":
            fileName = "Test"
        default:
            fileName = "PlacesSmolensk"
        }
        
        guard
            let fileName = Bundle.main.url(forResource: fileName, withExtension: "geojson"),
            let placesData = try? Data(contentsOf: fileName)
        else { return }
        do {
            let features = try MKGeoJSONDecoder()
                .decode(placesData)
                .compactMap {$0 as? MKGeoJSONFeature}
            
            let validWorks = features.compactMap(Places.init)
            places.append(contentsOf: validWorks)
        } catch {
            print ("\(error)")
        }
    }
    
    func createDirectionRequest(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) async throws -> Double {
       let startLocation = MKPlacemark(coordinate: startCoordinate)
       let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
       
       let request = MKDirections.Request()
       request.source = MKMapItem(placemark: startLocation)
       request.destination = MKMapItem(placemark: destinationLocation)
       request.transportType = .walking
       request.requestsAlternateRoutes = true
       
       let direction = MKDirections(request: request)
       let time2 = try await direction.calculate().routes[0].expectedTravelTime/180
    
       print("внутри crDirR \(time2)")
       return time2
   }
   
    @objc func routeButtonTapped() {
        async {
            print("StartA")
            //var places: [Places] = []
            /*let a = CLLocationCoordinate2D(latitude: 54.78858495164944, longitude:  32.05470512883579)
            let b = CLLocationCoordinate2D(latitude: 54.779619164622865, longitude:  32.04564361534319)
            let t = try await createDirectionRequest(startCoordinate: a, destinationCoordinate: b)
            print("t =  \(t)")*/
            let t = try await createDirectionRequest(startCoordinate: places[0].coordinate, destinationCoordinate: places[1].coordinate)
            print("t =  \(t)")
            print("FinishA")
        }
        
    }*/
}
