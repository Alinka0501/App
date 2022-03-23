//
//  PlacesViews.swift
//  AppCyciingRoute
//
//  Created by Ivan Bolotin on 08.01.2022.
//

import Foundation
import MapKit

class PlacesMarkersView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let places = newValue as? Places else {
                return
            }
            
            //отображение маркеров с буквой
            markerTintColor = places.markerTintColor
            if let letter = places.discipline?.first {
                glyphText = String(letter)
            }
        }
    }
}
