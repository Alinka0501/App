//
//  Places.swift
//  AppCyciingRoute
//
//  Created by Ivan Bolotin on 07.01.2022.
//

import Foundation
import MapKit
import Contacts

class Places: NSObject, MKAnnotation {
    let title: String?
    let locationName: String?
    let discipline: String?
    let coordinate: CLLocationCoordinate2D
    
    init (
        title: String?,
        locationName: String?,
        discipline: String?,
        coordinate: CLLocationCoordinate2D
    ) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        
        super.init()
    }
    
    init?(feature: MKGeoJSONFeature) {
        guard
            let point = feature.geometry.first as? MKPointAnnotation,
            let propertiesData = feature.properties,
            let json = try? JSONSerialization.jsonObject(with: propertiesData),
            let properties = json as? [String: Any]
        else {
            return nil
        }
        
        title = properties["title"] as? String
        locationName = properties["locationName"] as? String
        discipline = properties["discipline"] as? String
        coordinate = point.coordinate
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
    
    var mapItem: MKMapItem? {
        guard let location = locationName else {
            return nil
        }
        let addressDict = [CNPostalAddressStreetKey: location]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }
    
    // Изменение цвета маркера
    var markerTintColor: UIColor {
        switch discipline {
        case "Cathedral": return .init(red: 202/255.0, green: 240/255.0, blue: 248/255.0, alpha: 1.0)
        case "History": return .init(red: 173/255.0, green: 232/255.0, blue: 244/255.0, alpha: 1.0)
        case "Monument": return .init(red: 144/255.0, green: 224/255.0, blue: 239/255.0, alpha: 1.0)
        case "Place": return .init(red: 72/255.0, green: 202/255.0, blue: 228/255.0, alpha: 1.0)
        case "Bridge": return .init(red: 0/255.0, green: 180/255.0, blue: 216/255.0, alpha: 1.0)
        case "Theatre": return .init(red: 0/255.0, green: 150/255.0, blue: 199/255.0, alpha: 1.0)
        case "Architecture": return .init(red: 0/255.0, green: 119/255.0, blue: 182/255.0, alpha: 1.0)
        case "Stadium": return .init(red: 2/255.0, green: 62/255.0, blue: 138/255.0, alpha: 1.0)
        case "Museum": return .init(red: 3/255.0, green: 4/255.0, blue: 94/255.0, alpha: 1.0)
        case "Я": return .yellow
        default:
            return .init(red: 202/255.0, green: 240/255.0, blue: 248/255.0, alpha: 1.0)
        }
    }
    
}
