//
//  SharedLocationData.swift
//  WeatherWise
//
//  Created by Misha Vakhrushin on 16.04.2025.
//

import Combine
import MapKit

final class SharedLocationData{
    static let shared = SharedLocationData()
    private init() {}
    
    @Published var selectedLocation: CLLocationCoordinate2D?
    @Published var selectedRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    func moveToLocation(_ coordinate: CLLocationCoordinate2D, spanDelta: Double = 0.05) {
        self.selectedRegion = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: spanDelta, longitudeDelta: spanDelta)
        )
    }
}
