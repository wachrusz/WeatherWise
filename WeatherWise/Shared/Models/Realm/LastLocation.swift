//
//  LastLocation.swift
//  WeatherWise
//
//  Created by Misha Vakhrushin on 14.04.2025.
//

import RealmSwift
import MapKit

// MARK: - Последнее местоположение
final class LastLocation: Object {
    @Persisted(primaryKey: true) var id: String = "last_location"
    @Persisted var latitude: Double = 0
    @Persisted var longitude: Double = 0
    @Persisted var timestamp: Date = Date()
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    convenience init(coordinate: CLLocationCoordinate2D) {
        self.init()
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.timestamp = Date()
    }
    
    convenience init(location: CLLocation) {
        self.init(coordinate: location.coordinate)
    }
}
